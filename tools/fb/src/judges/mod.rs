//! `fb judges`: a judge's standing-order requirements as a layer over the court's layout (docs/JUDGES.md).
//!
//!   fb judges sources                              the courts a judge feed covers (data/judge-sources.json)
//!   fb judges sync <alias> [--judge <slug>] [--feed FILE] [--no-verify] [--cached]
//!                                                  read the feed, write <court>/judges/<slug>.yaml
//!   fb judges list <alias>                         the profiles of a court, one a line
//!   fb judges show <alias> <slug> [doctype]        a profile, and what it changes in a doc type's layout
//!   fb judges check <alias> [doctype]              every profile against the doc type's layout; exit 1 on a conflict
//!   fb build <alias> <doctype> <brief.md> [out.pdf] --judge <slug>     (build.rs)
//!
//! A feed (LawSnap's per-court JSON) quotes each judge's orders field by field and cites the PDF the court hosts.
//! `sync` reads typed facts out of the quotes (extract.rs), finds each quoted sentence in the cited PDF (verify.rs)
//! and writes one small profile a judge. The feed is the index; the court's document is the authority: a profile
//! holds the court's words and the facts read from them, never the feed's own commentary.
pub mod apply;
pub mod build;
pub mod extract;
pub mod verify;

use crate::{fail, repo_root, Res};
use serde::{Deserialize, Serialize};
use serde_json::Value as Json;
use std::collections::BTreeMap;
use std::path::{Path, PathBuf};
use std::process::{Command, ExitCode};

const USAGE: &str = "usage: fb judges sources | sync <alias> [--judge <slug>] [--feed FILE] [--no-verify] [--cached] | list <alias> | show <alias> <slug> [doctype] | check <alias> [doctype]";

/// The feeds and the courts they cover (data/judge-sources.json).
#[derive(Debug, Deserialize)]
pub struct Sources {
    pub provider: String,
    /// The feed of a court: `{slug}` is the provider's name for it.
    pub feed: String,
    /// A judge's page at the provider: `{slug}`, `{judge}`.
    pub page: String,
    /// The hosts whose documents count as the court's own (a suffix: `uscourts.gov`).
    pub primary_hosts: Vec<String>,
    /// formbook alias to the provider's court slug.
    pub courts: BTreeMap<String, String>,
    /// A court's own index of its judges' documents, by alias.
    #[serde(default)]
    pub court_index: BTreeMap<String, CourtIndex>,
}

/// A court's index of a judge's documents: the judge's page `<page_prefix><name>` has an API answer at
/// `<api_prefix><name>` whose `documents: [{id}]` are the files `<file_prefix><id>` (C.D. Cal.'s Judges' Procedures).
#[derive(Debug, Clone, Deserialize)]
pub struct CourtIndex {
    pub page_prefix: String,
    pub api_prefix: String,
    pub file_prefix: String,
}

pub fn sources(root: &Path) -> Res<Sources> {
    let p = root.join("data/judge-sources.json");
    let text = std::fs::read_to_string(&p)
        .map_err(|e| fail(2, format!("fb judges: {}: {e}", p.display())))?;
    serde_json::from_str(&text).map_err(|e| fail(2, format!("fb judges: {}: {e}", p.display())))
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Judge {
    pub slug: String,
    pub name: String,
    #[serde(default, skip_serializing_if = "String::is_empty")]
    pub title: String,
    pub court: String,
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Source {
    pub provider: String,
    pub page: String,
    pub feed: String,
    /// The date the provider last checked the judge's orders.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub last_verified: Option<String>,
    /// The judge's page at the court.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub court_page: Option<String>,
}

/// One requirement read from the judge's order: `id` and `value` (extract.rs), the sentence that states it, and
/// whether that sentence was found in the court-hosted document at `url`.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Fact {
    pub id: String,
    pub value: serde_yaml::Value,
    pub quote: String,
    /// The feed's field the sentence came from.
    pub field: String,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub url: Option<String>,
    pub verified: bool,
    /// The SHA-256 of the document the sentence was found in.
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub pdf_sha256: Option<String>,
    /// Where the sentence was found when not in the document its own field cites: `other-cited` (another document
    /// the feed cites for the judge) or `court-index` (a document the court's own index lists for the judge).
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub matched: Option<String>,
}

/// Where a candidate document comes from: the field's own citation, another of the feed's citations for the judge,
/// or the court's own index of the judge's documents.
#[derive(Debug, Clone, Copy, PartialEq)]
enum Origin {
    Cited,
    OtherCited,
    CourtIndex,
}

impl Origin {
    fn matched(self) -> Option<String> {
        match self {
            Origin::Cited => None,
            Origin::OtherCited => Some("other-cited".into()),
            Origin::CourtIndex => Some("court-index".into()),
        }
    }
}

/// A requirement the render cannot enforce (a hearing day, a proposed order by email): its topic, where the order
/// states it, and the order's sentences that were found in the court-hosted document.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Item {
    pub topic: String,
    pub field: String,
    #[serde(default, skip_serializing_if = "Option::is_none")]
    pub url: Option<String>,
    #[serde(default, skip_serializing_if = "String::is_empty")]
    pub text: String,
    /// The feed's sentences not found in the document, and so not kept.
    #[serde(default, skip_serializing_if = "is_zero")]
    pub unverified_sentences: usize,
}

fn is_zero(n: &usize) -> bool {
    *n == 0
}

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub struct Profile {
    pub judge: Judge,
    pub source: Source,
    #[serde(default)]
    pub facts: Vec<Fact>,
    #[serde(default)]
    pub checklist: Vec<Item>,
    /// Sentences that name a size or a limit and gave no fact: for a person to read.
    #[serde(default, skip_serializing_if = "Vec::is_empty")]
    pub review: Vec<String>,
}

impl Profile {
    pub fn fact(&self, id: &str) -> Option<&Fact> {
        self.facts.iter().find(|f| f.id == id)
    }
}

const HEADER: &str = "# Generated by `fb judges sync` (tools/fb/src/judges, docs/JUDGES.md): do not edit; sync again.\n\
# Each fact is read from one sentence of the judge's own order (`quote`) and is `verified` when that sentence is in the\n\
# court-hosted document at `url`. The checklist keeps only sentences found there. Check the order before you file.\n";

pub fn write_profile(path: &Path, p: &Profile) -> Res<bool> {
    let body = serde_yaml::to_string(p).map_err(|e| fail(2, format!("fb judges: {e}")))?;
    let text = format!("{HEADER}{body}");
    if std::fs::read_to_string(path).ok().as_deref() == Some(text.as_str()) {
        return Ok(false);
    }
    if let Some(d) = path.parent() {
        std::fs::create_dir_all(d)
            .map_err(|e| fail(2, format!("fb judges: {}: {e}", d.display())))?;
    }
    std::fs::write(path, text)
        .map_err(|e| fail(2, format!("fb judges: {}: {e}", path.display())))?;
    Ok(true)
}

pub fn read_profile(path: &Path) -> Res<Profile> {
    let text = std::fs::read_to_string(path)
        .map_err(|e| fail(1, format!("fb judges: {}: {e}", path.display())))?;
    serde_yaml::from_str(&text).map_err(|e| fail(2, format!("fb judges: {}: {e}", path.display())))
}

/// The folder of the court `alias` (data/index.json).
pub fn court_dir(root: &Path, alias: &str) -> Res<PathBuf> {
    let p = root.join("data/index.json");
    let index: Json = std::fs::read(&p)
        .ok()
        .and_then(|b| serde_json::from_slice(&b).ok())
        .ok_or_else(|| fail(2, format!("fb judges: cannot read {}", p.display())))?;
    let alias = index["legacy_aliases"][alias].as_str().unwrap_or(alias);
    index["courts"][alias]["path"]
        .as_str()
        .map(|p| root.join(p))
        .filter(|d| d.is_dir())
        .ok_or_else(|| {
            fail(
                1,
                format!("fb judges: no court '{alias}' (data/index.json)"),
            )
        })
}

pub fn profile_path(court: &Path, slug: &str) -> PathBuf {
    court.join("judges").join(format!("{slug}.yaml"))
}

/// The profiles of a court folder, by slug.
pub fn profiles(court: &Path) -> Res<Vec<Profile>> {
    let mut files: Vec<PathBuf> = std::fs::read_dir(court.join("judges"))
        .into_iter()
        .flatten()
        .flatten()
        .map(|e| e.path())
        .filter(|p| {
            p.extension().is_some_and(|x| x == "yaml")
                && !p
                    .file_name()
                    .is_some_and(|n| n.to_string_lossy().starts_with('_'))
        })
        .collect();
    files.sort();
    files.iter().map(|f| read_profile(f)).collect()
}

/// A judge's slug is a file name: lower-case letters, digits and hyphens.
pub fn slug_ok(s: &str) -> bool {
    !s.is_empty()
        && s.len() <= 80
        && s.chars()
            .all(|c| c.is_ascii_lowercase() || c.is_ascii_digit() || c == '-')
}

/// The checklist topics, by the feed's field.
const TOPICS: [(&str, &str); 15] = [
    ("motion_hearing_days", "Motion hearing days"),
    ("motion_notice_days", "Notice and briefing schedule"),
    ("oral_argument_default", "Oral argument"),
    ("proposed_orders", "Proposed orders"),
    ("chambers_copies_details", "Chambers copies"),
    ("under_seal_requirements", "Filing under seal"),
    ("ex_parte_notice", "Ex parte applications"),
    ("discovery_referral", "Discovery disputes"),
    ("ecf_stamp_requirements", "Exhibits and ECF"),
    ("ai_disclosure_requirement", "Generative AI"),
    ("tentative_rulings", "Tentative rulings"),
    ("remote_appearances", "Remote appearances"),
    ("continuances_calendar_conflicts", "Continuances"),
    ("lead_counsel_requirement", "Lead counsel"),
    ("settlement_notification", "Notice of settlement"),
];

/// Where a sentence of the feed that the court's document does not hold was left out of a checklist text.
const OMITTED: &str = "[...]";

/// The fields the type facts and the length facts are read from.
const FONT_FIELDS: [&str; 2] = ["font_formatting", "footnote_policy"];
const LENGTH_FIELDS: [&str; 3] = [
    "page_limits_motions",
    "page_limits_oppositions",
    "page_limits_replies",
];

/// A field's text, when the feed has something to say ("Silent on ..." is the feed's word for nothing).
fn field<'a>(j: &'a Json, k: &str) -> Option<&'a str> {
    j[k].as_str().map(str::trim).filter(|s| {
        !s.is_empty()
            && !s.to_lowercase().starts_with("silent on")
            && !s.eq_ignore_ascii_case("none")
    })
}

/// The documents of a judge, fetched once each.
struct Docs<'a> {
    cache: PathBuf,
    hosts: &'a [String],
    on: bool,
    loaded: BTreeMap<String, Result<verify::Corpus, String>>,
}

/// How a sentence is looked for in a document: a fact's whole sentence (verify::holds_fact), or a checklist
/// sentence, whose elided pieces may each be found in order (verify::holds).
#[derive(Clone, Copy)]
enum Match {
    Fact,
    Checklist,
}

impl Docs<'_> {
    /// The first of `urls` (court-hosted) whose document holds `quote`: its URL as cited, the document's hash and
    /// where the document comes from.
    fn find(
        &mut self,
        urls: &[(String, Origin)],
        quote: &str,
        how: Match,
    ) -> Option<(String, String, Origin)> {
        if !self.on {
            return None;
        }
        for (u, origin) in urls {
            if !verify::court_hosted(u, self.hosts) {
                continue;
            }
            let key = verify::bare(u).to_string();
            let cache = self.cache.clone();
            let hosts = self.hosts;
            let doc = self
                .loaded
                .entry(key)
                .or_insert_with_key(|k| verify::load(k, &cache, hosts));
            if let Ok(c) = doc {
                let ok = match how {
                    Match::Fact => verify::holds_fact(&c.text, quote),
                    Match::Checklist => verify::holds(&c.text, quote),
                };
                if ok {
                    return Some((u.clone(), c.sha256.clone(), *origin));
                }
            }
        }
        None
    }
}

/// The URLs to look a field's sentences up in: the field's own citation first, then the judge's other documents,
/// then what the court's own index lists for the judge today (`extra`).
fn candidates(j: &Json, k: &str, extra: &[String]) -> Vec<(String, Origin)> {
    let mut out: Vec<(String, Origin)> = Vec::new();
    let mut push = |u: Option<&str>, origin: Origin| {
        if let Some(u) = u {
            if !out.iter().any(|(o, _)| verify::bare(o) == verify::bare(u)) {
                out.push((u.to_string(), origin));
            }
        }
    };
    push(j["citations"][k]["url"].as_str(), Origin::Cited);
    for (_, c) in j["citations"].as_object().into_iter().flatten() {
        push(c["url"].as_str(), Origin::OtherCited);
    }
    for u in extra {
        push(Some(u), Origin::CourtIndex);
    }
    out
}

/// A judge's name in a court index's URLs: Unicode letters and digits and hyphens, nothing that could leave the path.
fn index_name_ok(name: &str) -> bool {
    !name.is_empty()
        && name.chars().count() <= 120
        && name.chars().all(|c| c.is_alphanumeric() || c == '-')
}

/// What the court's own index lists for the judge: the API answer of the judge's page, then its documents.
fn court_listed(j: &Json, index: Option<&CourtIndex>, docs: &Docs) -> Vec<String> {
    let (Some(ix), Some(page)) = (index, j["verifyUrl"].as_str()) else {
        return vec![];
    };
    let Some(name) = page
        .strip_prefix(&ix.page_prefix)
        .filter(|n| index_name_ok(n) && docs.on)
    else {
        return vec![];
    };
    let api = format!("{}{name}", ix.api_prefix);
    let mut out = verify::listed_documents(&api, &ix.file_prefix, &docs.cache, docs.hosts);
    out.insert(0, api);
    out
}

/// The profile of one judge of the feed.
fn profile_of(j: &Json, alias: &str, src: &Sources, court_slug: &str, docs: &mut Docs) -> Profile {
    let text = |k: &str| j[k].as_str().unwrap_or("").to_string();
    let slug = text("slug");
    let listed = court_listed(j, src.court_index.get(alias), docs);
    let mut facts: Vec<Fact> = Vec::new();
    let mut review: Vec<String> = Vec::new();
    // ids two fields gave two values for: no fact for the rest of the judge (extract::dedupe, across fields)
    let mut dropped: Vec<String> = Vec::new();
    let mut take = |fields: &[&str], read: fn(&str) -> (Vec<extract::Found>, Vec<String>)| {
        for k in fields {
            let Some(t) = field(j, k) else { continue };
            let (found, rev) = read(t);
            review.extend(rev);
            for f in found {
                if dropped.contains(&f.id) {
                    review.push(format!("{} (two values): {}", f.id, f.quote));
                    continue;
                }
                match facts.iter().position(|o| o.id == f.id) {
                    Some(i) if facts[i].value == f.value => {}
                    Some(i) => {
                        // two fields, two values: neither is a fact
                        let old = facts.remove(i);
                        review.push(format!("{} (two values): {}", old.id, old.quote));
                        review.push(format!("{} (two values): {}", f.id, f.quote));
                        dropped.push(f.id);
                    }
                    None => {
                        let urls = candidates(j, k, &listed);
                        let hit = docs.find(&urls, &f.quote, Match::Fact);
                        facts.push(Fact {
                            id: f.id,
                            value: f.value,
                            quote: f.quote,
                            field: k.to_string(),
                            url: hit
                                .as_ref()
                                .map(|h| h.0.clone())
                                .or_else(|| urls.first().map(|u| u.0.clone())),
                            verified: hit.is_some(),
                            pdf_sha256: hit.as_ref().map(|h| h.1.clone()),
                            matched: hit.and_then(|h| h.2.matched()),
                        });
                    }
                }
            }
        }
    };
    take(&FONT_FIELDS, extract::fonts);
    take(&LENGTH_FIELDS, extract::lengths);
    // an order often states its type sizes beside its limits ("Limit any reply to 2,500 words. Use 14-point font ...")
    take(&LENGTH_FIELDS, extract::fonts);
    review.sort();
    review.dedup();
    let mut checklist = Vec::new();
    for (k, topic) in TOPICS {
        let Some(t) = field(j, k) else { continue };
        let urls = candidates(j, k, &listed);
        // the sentences found in the court's document, in order; `[...]` where one that was not is left out
        let mut kept: Vec<String> = Vec::new();
        let mut dropped = 0;
        for s in extract::sentences(t) {
            let q = extract::clean_quote(&s);
            if q.chars().count() < 25 {
                continue;
            }
            if docs.find(&urls, &q, Match::Checklist).is_some() {
                if !kept.contains(&q) {
                    kept.push(q);
                }
            } else {
                dropped += 1;
                if kept.last().is_some_and(|l| l != OMITTED) {
                    kept.push(OMITTED.to_string());
                }
            }
        }
        if kept.last().is_some_and(|l| l == OMITTED) {
            kept.pop();
        }
        checklist.push(Item {
            topic: topic.to_string(),
            field: k.to_string(),
            url: urls.first().map(|u| u.0.clone()),
            text: kept.join(" "),
            unverified_sentences: dropped,
        });
    }
    Profile {
        judge: Judge {
            slug: slug.clone(),
            name: text("fullName"),
            title: text("judgeType"),
            court: alias.to_string(),
        },
        source: Source {
            provider: src.provider.clone(),
            page: src
                .page
                .replace("{slug}", court_slug)
                .replace("{judge}", &slug),
            feed: src.feed.replace("{slug}", court_slug),
            last_verified: j["lastVerified"].as_str().map(str::to_string),
            court_page: j["verifyUrl"].as_str().map(str::to_string),
        },
        facts,
        checklist,
        review,
    }
}

fn opt<'a>(args: &'a [String], name: &str) -> Option<&'a str> {
    args.iter()
        .position(|a| a == name)
        .and_then(|i| args.get(i + 1))
        .map(String::as_str)
}

/// The arguments that are neither options nor an option's value.
fn positional<'a>(args: &'a [String], valued: &[&str]) -> Vec<&'a str> {
    let mut out = Vec::new();
    let mut it = args.iter();
    while let Some(a) = it.next() {
        if valued.contains(&a.as_str()) {
            it.next();
        } else if !a.starts_with("--") {
            out.push(a.as_str());
        }
    }
    out
}

fn sync(args: &[String]) -> Res<ExitCode> {
    let pos = positional(args, &["--judge", "--feed"]);
    let [alias] = pos.as_slice() else {
        return Err(fail(2, USAGE));
    };
    let root = repo_root()?;
    let src = sources(&root)?;
    let court_slug = src.courts.get(*alias).ok_or_else(|| {
        fail(
            1,
            format!("fb judges sync: no feed covers '{alias}' (fb judges sources)"),
        )
    })?;
    let court = court_dir(&root, alias)?;
    let cache = root.join("out/judges-cache");
    // a court replaces an order at the same URL: every sync reads the documents afresh unless told otherwise
    if !args.iter().any(|a| a == "--cached") && cache.exists() {
        std::fs::remove_dir_all(&cache)
            .map_err(|e| fail(2, format!("fb judges sync: {}: {e}", cache.display())))?;
    }
    let feed: Json = match opt(args, "--feed") {
        Some(f) => {
            let b = std::fs::read(f).map_err(|e| fail(2, format!("fb judges sync: {f}: {e}")))?;
            serde_json::from_slice(&b).map_err(|e| fail(2, format!("fb judges sync: {f}: {e}")))?
        }
        None => {
            let url = src.feed.replace("{slug}", court_slug);
            let out = Command::new("curl")
                .args([
                    "-fsSL",
                    "--proto",
                    "=https",
                    "--proto-redir",
                    "=https",
                    "--retry",
                    "2",
                    "--max-time",
                    "120",
                    &url,
                ])
                .output()
                .map_err(|e| fail(2, format!("fb judges sync: curl: {e}")))?;
            if !out.status.success() {
                return Err(fail(
                    1,
                    format!(
                        "fb judges sync: {url}: curl exit {}",
                        out.status.code().unwrap_or(-1)
                    ),
                ));
            }
            serde_json::from_slice(&out.stdout)
                .map_err(|e| fail(1, format!("fb judges sync: {url}: {e}")))?
        }
    };
    let judges = feed["judges"]
        .as_array()
        .ok_or_else(|| fail(1, "fb judges sync: the feed has no `judges` list"))?;
    let only = opt(args, "--judge");
    let mut seen = Vec::new();
    let mut changed = 0;
    for j in judges {
        let slug = j["slug"].as_str().unwrap_or("");
        if !slug_ok(slug) {
            eprintln!("SKIP  {alias} {slug:?}: not a slug");
            continue;
        }
        seen.push(slug.to_string());
        if only.is_some_and(|o| o != slug) {
            continue;
        }
        let mut docs = Docs {
            cache: cache.clone(),
            hosts: &src.primary_hosts,
            on: !args.iter().any(|a| a == "--no-verify"),
            loaded: BTreeMap::new(),
        };
        let p = profile_of(j, alias, &src, court_slug, &mut docs);
        let wrote = write_profile(&profile_path(&court, slug), &p)?;
        changed += usize::from(wrote);
        let unread: Vec<String> = docs
            .loaded
            .iter()
            .filter_map(|(u, d)| d.as_ref().err().map(|e| format!("{u}: {e}")))
            .collect();
        println!(
            "{}  {alias} {slug}: {} facts ({} verified), {} checklist topics{}{}",
            if wrote { "WROTE" } else { "SAME " },
            p.facts.len(),
            p.facts.iter().filter(|f| f.verified).count(),
            p.checklist.len(),
            if p.review.is_empty() {
                String::new()
            } else {
                format!(", {} to review", p.review.len())
            },
            if unread.is_empty() {
                String::new()
            } else {
                format!("; unread: {}", unread.join("; "))
            },
        );
    }
    if let Some(o) = only {
        if !seen.iter().any(|s| s == o) {
            return Err(fail(
                1,
                format!("fb judges sync: the feed has no judge '{o}'"),
            ));
        }
    } else {
        for p in profiles(&court)? {
            if !seen.contains(&p.judge.slug) {
                println!("GONE   {alias} {}: not in the feed any more (the profile is kept; delete it by hand)", p.judge.slug);
            }
        }
    }
    println!(
        "{} profile(s) written under {}",
        changed,
        court
            .join("judges")
            .strip_prefix(&root)
            .unwrap_or(&court)
            .display()
    );
    Ok(ExitCode::SUCCESS)
}

fn value_text(v: &serde_yaml::Value) -> String {
    match v {
        serde_yaml::Value::Number(n) => n
            .as_f64()
            .map(crate::enginegen::gen::fmt)
            .unwrap_or_else(|| n.to_string()),
        serde_yaml::Value::Bool(b) => b.to_string(),
        serde_yaml::Value::String(s) => s.clone(),
        v => serde_yaml::to_string(v)
            .unwrap_or_default()
            .trim()
            .to_string(),
    }
}

/// The doc folders of a court on the shared layout model (`<doctype>/typst/layout.yaml`), or the one named.
fn model_folders(court: &Path, doctype: Option<&str>) -> Vec<PathBuf> {
    let mut out: Vec<PathBuf> = std::fs::read_dir(court)
        .into_iter()
        .flatten()
        .flatten()
        .map(|e| e.path())
        .filter(|p| p.join("typst/layout.yaml").is_file())
        .filter(|p| doctype.is_none_or(|d| p.file_name().is_some_and(|n| n == d)))
        .collect();
    out.sort();
    out
}

fn show(args: &[String]) -> Res<ExitCode> {
    let (alias, slug, doctype) = match args {
        [a, s] => (a, s, None),
        [a, s, d] => (a, s, Some(d.as_str())),
        _ => return Err(fail(2, USAGE)),
    };
    // the slug names a file under the court folder: never a path
    if !slug_ok(slug) {
        return Err(fail(
            2,
            format!("fb judges show: '{slug}' is not a judge's slug (lower-case letters, digits and hyphens)"),
        ));
    }
    let root = repo_root()?;
    let court = court_dir(&root, alias)?;
    let p = read_profile(&profile_path(&court, slug))?;
    println!(
        "{} ({}), {}",
        p.judge.name,
        if p.judge.title.is_empty() {
            "judge"
        } else {
            &p.judge.title
        },
        p.judge.court
    );
    println!("  feed page   {}", p.source.page);
    if let Some(u) = &p.source.court_page {
        println!("  court page  {u}");
    }
    if let Some(d) = &p.source.last_verified {
        println!("  the feed last checked the orders on {d}");
    }
    println!("\nFacts ({}):", p.facts.len());
    for f in &p.facts {
        println!(
            "  {:<24} {:<16} {}",
            f.id,
            value_text(&f.value),
            if f.verified { "verified" } else { "UNVERIFIED" }
        );
        println!("      \u{201C}{}\u{201D}", f.quote);
        if let Some(u) = &f.url {
            println!("      {u}");
        }
        match f.matched.as_deref() {
            Some("other-cited") => println!("      (found in another document the feed cites for the judge, not in the one its field cites: read it in context)"),
            Some("court-index") => println!("      (found in a document the court's index lists for the judge, not in the one the feed cites: read it in context)"),
            Some(m) => println!("      (matched: {m})"),
            None => {}
        }
    }
    for folder in model_folders(&court, doctype) {
        let name = folder
            .file_name()
            .unwrap_or_default()
            .to_string_lossy()
            .into_owned();
        for paper in apply::PAPERS {
            println!("\nOn {name}, for the paper `{paper}`:");
            for l in build::outcome(&root, &folder, &p, paper, None, false)?.lines {
                println!("  {l}");
            }
        }
    }
    println!("\nChecklist (the render does not enforce these):");
    for i in &p.checklist {
        println!(
            "  {}{}",
            i.topic,
            i.url.as_ref().map(|u| format!("  {u}")).unwrap_or_default()
        );
        if !i.text.is_empty() {
            println!("      {}", i.text);
        }
        if i.unverified_sentences > 0 {
            println!("      ({} sentence(s) of the feed not found in the court's document: read the order)", i.unverified_sentences);
        }
    }
    if !p.review.is_empty() {
        println!("\nTo review (a size or a limit the reader did not take):");
        for r in &p.review {
            println!("  {r}");
        }
    }
    Ok(ExitCode::SUCCESS)
}

fn list(args: &[String]) -> Res<ExitCode> {
    let [alias] = args else {
        return Err(fail(2, USAGE));
    };
    let root = repo_root()?;
    for p in profiles(&court_dir(&root, alias)?)? {
        let facts: Vec<String> = p
            .facts
            .iter()
            .map(|f| {
                format!(
                    "{}={}{}",
                    f.id,
                    value_text(&f.value),
                    if f.verified { "" } else { "?" }
                )
            })
            .collect();
        println!("{}\t{}\t{}", p.judge.slug, p.judge.name, facts.join(" "));
    }
    Ok(ExitCode::SUCCESS)
}

fn check(args: &[String]) -> Res<ExitCode> {
    let (alias, doctype) = match args {
        [a] => (a, None),
        [a, d] => (a, Some(d.as_str())),
        _ => return Err(fail(2, USAGE)),
    };
    let root = repo_root()?;
    let court = court_dir(&root, alias)?;
    let folders = model_folders(&court, doctype);
    if folders.is_empty() {
        return Err(fail(
            1,
            format!("fb judges check: no doc type of '{alias}' is on the shared layout model"),
        ));
    }
    let all = profiles(&court)?;
    let (mut conflicts, mut unverified) = (0, 0);
    for p in &all {
        for folder in &folders {
            let name = folder
                .file_name()
                .unwrap_or_default()
                .to_string_lossy()
                .into_owned();
            for paper in apply::PAPERS {
                for l in build::outcome(&root, folder, p, paper, None, false)?.lines {
                    match l.status {
                        apply::Status::Conflict => conflicts += 1,
                        apply::Status::Unverified => unverified += 1,
                        _ => continue,
                    }
                    println!("{} {name} {paper}: {l}", p.judge.slug);
                }
            }
        }
    }
    println!(
        "RESULT judges {alias}: {} profile(s), {} doc type(s), {conflicts} conflict(s), {unverified} unverified change(s)",
        all.len(),
        folders.len()
    );
    Ok(if conflicts > 0 {
        ExitCode::from(1)
    } else {
        ExitCode::SUCCESS
    })
}

pub fn main(args: &[String]) -> Res<ExitCode> {
    match args.split_first() {
        Some((c, _)) if c == "sources" => {
            let s = sources(&repo_root()?)?;
            for (alias, slug) in &s.courts {
                println!(
                    "{alias}\t{}\t{}",
                    s.provider,
                    s.feed.replace("{slug}", slug)
                );
            }
            Ok(ExitCode::SUCCESS)
        }
        Some((c, rest)) if c == "sync" => sync(rest),
        Some((c, rest)) if c == "list" => list(rest),
        Some((c, rest)) if c == "show" => show(rest),
        Some((c, rest)) if c == "check" => check(rest),
        _ => Err(fail(2, USAGE)),
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::json;

    fn src() -> Sources {
        Sources {
            provider: "lawsnap".into(),
            feed: "https://lawsnap.example/data/{slug}-judges.json".into(),
            page: "https://lawsnap.example/courts/{slug}/judges/{judge}/".into(),
            primary_hosts: vec!["uscourts.gov".into()],
            courts: BTreeMap::from([("cacd".to_string(), "ca-cd".to_string())]),
            court_index: BTreeMap::new(),
        }
    }

    #[test]
    fn a_profile_takes_facts_from_the_fields_and_none_of_the_commentary() {
        let j = json!({
            "slug": "doe-jane", "fullName": "Jane Doe", "judgeType": "District Judge", "lastVerified": "2026-09-04",
            "verifyUrl": "https://apps.cacd.uscourts.gov/Jps/doe",
            "font_formatting": "SO 3: \"Times New Roman font must be no less than fourteen (14) point. Footnotes shall be in 12-point font.\"",
            "footnote_policy": "Silent on footnotes.",
            "page_limits_motions": "Memoranda shall not exceed 7,000 words.",
            "page_limits_replies": "Replies shall not exceed 4,200 words.",
            "proposed_orders": "A copy of the proposed order in Word format shall be emailed to chambers on the day of filing.",
            "key_traps": ["the feed's own commentary, never copied"],
            "citations": {"font_formatting": {"url": "https://apps.cacd.uscourts.gov/JpsApi/file/abc#page=6"}}
        });
        let mut docs = Docs {
            cache: PathBuf::from("/nonexistent"),
            hosts: &[],
            on: false,
            loaded: BTreeMap::new(),
        };
        let p = profile_of(&j, "cacd", &src(), "ca-cd", &mut docs);
        let ids: Vec<&str> = p.facts.iter().map(|f| f.id.as_str()).collect();
        assert_eq!(
            ids,
            [
                "body.min_pt",
                "footnote.exact_pt",
                "words.memorandum",
                "words.reply"
            ]
        );
        assert!(p
            .facts
            .iter()
            .all(|f| !f.verified && f.pdf_sha256.is_none()));
        assert_eq!(
            p.facts[0].url.as_deref(),
            Some("https://apps.cacd.uscourts.gov/JpsApi/file/abc#page=6")
        );
        assert_eq!(
            p.source.page,
            "https://lawsnap.example/courts/ca-cd/judges/doe-jane/"
        );
        // unverified: the topic and where to read it, none of the text
        assert_eq!(p.checklist.len(), 1);
        assert_eq!(
            (
                p.checklist[0].topic.as_str(),
                p.checklist[0].text.as_str(),
                p.checklist[0].unverified_sentences
            ),
            ("Proposed orders", "", 1)
        );
        let yaml = serde_yaml::to_string(&p).unwrap();
        assert!(!yaml.contains("commentary"));
        assert_eq!(serde_yaml::from_str::<Profile>(&yaml).unwrap(), p);
    }

    #[test]
    fn two_values_across_fields_drop_the_id_for_the_rest_of_the_judge() {
        let j = json!({
            "slug": "doe-jane", "fullName": "Jane Doe",
            "font_formatting": "Footnotes shall be in 12-point font.",
            "footnote_policy": "Footnotes shall be in 14-point font.",
            "page_limits_motions": "Footnotes shall be in 12-point font. Memoranda shall not exceed 7,000 words."
        });
        let mut docs = Docs {
            cache: PathBuf::from("/nonexistent"),
            hosts: &[],
            on: false,
            loaded: BTreeMap::new(),
        };
        let p = profile_of(&j, "cacd", &src(), "ca-cd", &mut docs);
        let ids: Vec<&str> = p.facts.iter().map(|f| f.id.as_str()).collect();
        assert_eq!(ids, ["words.memorandum"]);
        assert_eq!(
            p.review
                .iter()
                .filter(|r| r.starts_with("footnote.exact_pt (two values)"))
                .count(),
            2,
            "{:?}",
            p.review
        );
    }

    #[test]
    fn a_sentence_found_in_another_document_says_where() {
        let cache = std::env::temp_dir().join(format!("fb-judges-test-{}", std::process::id()));
        let _ = std::fs::remove_dir_all(&cache);
        std::fs::create_dir_all(&cache).unwrap();
        let put = |url: &str, body: &str| {
            let name = format!("{}.pdf", &verify::sha256(url.as_bytes())[..24]);
            std::fs::write(cache.join(name), body).unwrap();
        };
        put(
            "https://ecf.cacd.uscourts.gov/a.html",
            "<html><body><p>Hearings are on Mondays.</p></body></html>",
        );
        put(
            "https://ecf.cacd.uscourts.gov/b.html",
            "<html><body><p>Memoranda shall not exceed 7,000 words.</p><p>Replies shall not exceed 4,000 words.</p></body></html>",
        );
        let j = json!({
            "slug": "doe-jane", "fullName": "Jane Doe",
            "page_limits_motions": "Memoranda shall not exceed 7,000 words.",
            "page_limits_replies": "Replies shall not exceed 4,000 words.",
            "citations": {
                "page_limits_motions": {"url": "https://ecf.cacd.uscourts.gov/a.html"},
                "page_limits_replies": {"url": "https://ecf.cacd.uscourts.gov/b.html"}
            }
        });
        let hosts = vec!["uscourts.gov".to_string()];
        let mut docs = Docs {
            cache: cache.clone(),
            hosts: &hosts,
            on: true,
            loaded: BTreeMap::new(),
        };
        let p = profile_of(&j, "cacd", &src(), "ca-cd", &mut docs);
        let _ = std::fs::remove_dir_all(&cache);
        let got: Vec<(&str, bool, Option<&str>)> = p
            .facts
            .iter()
            .map(|f| (f.id.as_str(), f.verified, f.matched.as_deref()))
            .collect();
        assert_eq!(
            got,
            [
                ("words.memorandum", true, Some("other-cited")),
                ("words.reply", true, None)
            ]
        );
        let yaml = serde_yaml::to_string(&p).unwrap();
        assert_eq!(yaml.matches("matched:").count(), 1);
    }

    #[test]
    fn a_court_index_name_is_letters_digits_and_hyphens() {
        assert!(index_name_ok("Aenlle-Rocha"));
        assert!(index_name_ok("Pe\u{f1}a-Mar\u{ed}a"));
        for bad in ["", "../x", "a/b", "a?b=c", "a b", "a%2F", "a.b", "a#b"] {
            assert!(!index_name_ok(bad), "{bad}");
        }
    }

    #[test]
    fn slugs_are_file_names() {
        assert!(slug_ok("aenlle-rocha-fernando"));
        assert!(!slug_ok("../etc"));
        assert!(!slug_ok("A"));
        assert!(!slug_ok(""));
    }
}
