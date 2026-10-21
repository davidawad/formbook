//! `fb bootstrap [--check]`: install the formbook toolchain without root (hosts have no apt): micromamba +
//! conda-forge into a private prefix, then verify every tool and print its version (was tools/bootstrap.sh).
//! `--check` verifies only and installs nothing. Idempotent: rerun to repair or re-pin. Exits non-zero if any
//! tool is missing or has the wrong version. Install root: $FORMBOOK_HOME (default
//! $HOME/.local/share/formbook). Needs cargo (to build fb) and, to install, curl, tar and bzip2.
use crate::proc::{capture, TempDir};
use crate::{fail, Res};
use sha2::{Digest, Sha256};
use std::path::{Path, PathBuf};
use std::process::{Command, ExitCode};

const TYPST_VERSION: &str = "0.15.1";
const MAMBA_VERSION: &str = "2.9.0";
const MAMBA_SHA256: &str = "8761c382127e6363bd9e0a2451aa3ef90d071a79133f736e2f759a3bf13040dd";
/// typst is pinned exactly: the court templates are written and checked against this release.
fn specs() -> Vec<String> {
    let mut s = vec![format!("typst=={TYPST_VERSION}")];
    s.extend(
        "poppler imagemagick gawk jq go-yq pandoc tectonic just zip unzip libxml2"
            .split(' ')
            .map(String::from),
    );
    s
}

fn sha256_hex(bytes: &[u8]) -> String {
    Sha256::digest(bytes)
        .iter()
        .map(|b| format!("{b:02x}"))
        .collect()
}

/// Outcome of probing one tool.
#[derive(Debug, PartialEq)]
enum Probe {
    Ok(String),
    Missing,
    Broken(String),
}

fn first_line(s: &str) -> &str {
    s.lines().next().unwrap_or("")
}

/// The report line for a probe of `name` found at `at`.
fn probe_line(name: &str, p: &Probe, at: &str) -> String {
    match p {
        Probe::Ok(out) => format!("ok       {}  [{at}]", first_line(out)),
        Probe::Missing => format!("MISSING  {name}"),
        Probe::Broken(out) => format!(
            "BROKEN   {name}: version probe exited non-zero: {}",
            first_line(out)
        ),
    }
}

/// `typst --version` is `typst X.Y.Z (hash)`; the version is its second word.
fn typst_version(out: &str) -> &str {
    out.split_whitespace().nth(1).unwrap_or("")
}

fn is_mikefarah(yq_version: &str) -> bool {
    yq_version.contains("mikefarah")
}

struct Env {
    path: std::ffi::OsString,
    fails: usize,
}

impl Env {
    fn find(&self, tool: &str) -> Option<PathBuf> {
        std::env::split_paths(&self.path)
            .map(|d| d.join(tool))
            .find(|f| f.is_file())
    }

    /// A tool passes if it is on PATH and its version probe exits 0; returns the probe output.
    fn probe(&mut self, tool: &str, args: &[&str]) -> Res<Option<String>> {
        let Some(at) = self.find(tool) else {
            println!("{}", probe_line(tool, &Probe::Missing, ""));
            self.fails += 1;
            return Ok(None);
        };
        let o = capture(Command::new(&at).args(args).env("PATH", &self.path))?;
        let out = format!(
            "{}{}",
            String::from_utf8_lossy(&o.stdout),
            String::from_utf8_lossy(&o.stderr)
        );
        if o.status.success() {
            println!(
                "{}",
                probe_line(tool, &Probe::Ok(out.clone()), &at.display().to_string())
            );
            Ok(Some(out))
        } else {
            println!("{}", probe_line(tool, &Probe::Broken(out), ""));
            self.fails += 1;
            Ok(None)
        }
    }

    /// For tools this script does not install.
    fn presence(&mut self, tool: &str) {
        match self.find(tool) {
            Some(at) => println!(
                "ok       {tool}  [{}] (not installed by this script)",
                at.display()
            ),
            None => {
                println!("MISSING  {tool} (not installed by this script)");
                self.fails += 1;
            }
        }
    }

    /// The check bridge needs a UTF-8 locale for gawk's character and case operations.
    fn utf8_locale(&mut self, locale: &str) -> Res<()> {
        let Some(gawk) = self.find("gawk") else {
            // The missing gawk probe already explains why the locale check cannot run.
            return Ok(());
        };
        let out = capture(
            Command::new(gawk)
                .args(["BEGIN { exit (length(\"“\") == 1 ? 0 : 1) }"])
                .env("LC_ALL", locale)
                .env("PATH", &self.path),
        )?;
        if out.status.success() {
            println!("ok       locale {locale} (gawk recognizes UTF-8 characters)");
        } else {
            println!("MISSING  locale {locale} (required by gawk checks)");
            self.fails += 1;
        }
        Ok(())
    }
}

fn sh(prog: &str, args: &[&str]) -> Res<()> {
    let st = Command::new(prog)
        .args(args)
        .status()
        .map_err(|e| fail(2, format!("fb bootstrap: cannot run {prog}: {e}")))?;
    st.success()
        .then_some(())
        .ok_or_else(|| fail(1, format!("fb bootstrap: {prog} failed with {st}")))
}

fn install_micromamba(mm: &Path) -> Res<()> {
    let tmp = TempDir::new("bootstrap")?;
    let archive = tmp.path().join("micromamba.tar.bz2");
    let bin_dir = mm
        .parent()
        .ok_or_else(|| fail(2, "fb bootstrap: bad micromamba path"))?;
    std::fs::create_dir_all(bin_dir)
        .map_err(|e| fail(2, format!("fb bootstrap: {}: {e}", bin_dir.display())))?;
    let url = format!(
        "https://conda.anaconda.org/conda-forge/linux-64/micromamba-{MAMBA_VERSION}-0.tar.bz2"
    );
    sh("curl", &["-fsSL", "-o", &archive.to_string_lossy(), &url])?;
    let bytes = std::fs::read(&archive).map_err(|e| fail(2, format!("fb bootstrap: {e}")))?;
    if sha256_hex(&bytes) != MAMBA_SHA256 {
        return Err(fail(
            1,
            format!("bootstrap: micromamba {MAMBA_VERSION} checksum mismatch"),
        ));
    }
    sh(
        "tar",
        &[
            "-xjf",
            &archive.to_string_lossy(),
            "-C",
            &tmp.path().to_string_lossy(),
            "bin/micromamba",
        ],
    )?;
    std::fs::copy(tmp.path().join("bin/micromamba"), mm)
        .map(|_| ())
        .map_err(|e| fail(2, format!("fb bootstrap: {}: {e}", mm.display())))
}

fn install(base: &Path, prefix: &Path) -> Res<()> {
    let mm = base.join("bin/micromamba");
    if !mm.is_file() {
        install_micromamba(&mm)?;
    }
    // install is a no-op when the prefix already satisfies the specs; create only for a fresh prefix.
    let verb = if prefix.join("conda-meta").is_dir() {
        "install"
    } else {
        "create"
    };
    let root = base.join("mamba-root");
    let mut args: Vec<String> = [verb, "-y", "--no-rc", "-r"].map(String::from).into();
    args.extend([
        root.to_string_lossy().into_owned(),
        "-p".into(),
        prefix.to_string_lossy().into_owned(),
    ]);
    args.extend(["-c", "conda-forge", "--override-channels"].map(String::from));
    args.extend(specs());
    let refs: Vec<&str> = args.iter().map(String::as_str).collect();
    sh(&mm.to_string_lossy(), &refs)
}

pub fn main(args: &[String]) -> Res<ExitCode> {
    let check_only = match args {
        [] => false,
        [a] if a == "--check" => true,
        _ => return Err(fail(2, "usage: fb bootstrap [--check]")),
    };
    let home = std::env::var("HOME").unwrap_or_default();
    let base = std::env::var_os("FORMBOOK_HOME").map_or_else(
        || PathBuf::from(&home).join(".local/share/formbook"),
        PathBuf::from,
    );
    let prefix = base.join("env");
    if !check_only {
        install(&base, &prefix)?;
    }
    // The env wins over any system copy (the host has /usr/bin/pandoc and /usr/bin/jq).
    let mut paths = vec![prefix.join("bin")];
    paths.extend(std::env::split_paths(
        &std::env::var_os("PATH").unwrap_or_default(),
    ));
    let mut env = Env {
        path: std::env::join_paths(paths)
            .map_err(|e| fail(2, format!("fb bootstrap: PATH: {e}")))?,
        fails: 0,
    };
    println!("bootstrap: toolchain prefix {}", prefix.display());
    if let Some(out) = env.probe("typst", &["--version"])? {
        let got = typst_version(&out);
        if got != TYPST_VERSION {
            println!("WRONG    typst is {got}, pinned {TYPST_VERSION}");
            env.fails += 1;
        }
    }
    // a failed probe is already counted and printed; the run goes on to report every tool
    env.probe("pdfinfo", &["-v"])?;
    for t in [
        "pdffonts",
        "pdftotext",
        "pdftohtml",
        "pdfimages",
        "pdftoppm",
    ] {
        env.probe(t, &["-v"])?;
    }
    env.probe("magick", &["-version"])?;
    env.probe("gawk", &["--version"])?;
    env.probe("jq", &["--version"])?;
    if let Some(out) = env.probe("yq", &["--version"])? {
        // the python yq also answers to "yq"; the template scripts need mikefarah's go-yq.
        if !is_mikefarah(&out) {
            println!("WRONG    yq is not mikefarah go-yq");
            env.fails += 1;
        }
    }
    env.probe("pandoc", &["--version"])?;
    env.probe("tectonic", &["--version"])?;
    env.probe("just", &["--version"])?;
    env.probe("zip", &["-v"])?;
    env.probe("unzip", &["-v"])?;
    env.probe("xmllint", &["--version"])?;
    env.probe("soffice", &["--version"])?;
    env.utf8_locale("C.UTF-8")?;
    env.presence("bend");
    env.presence("br");
    println!();
    if env.find("soffice").is_none() {
        println!("note: LibreOffice (soffice) has no conda-forge package; the docx engine needs it installed another way");
    }
    if env.fails > 0 {
        return Err(fail(
            1,
            format!(
                "bootstrap: {} tool(s) missing or wrong (see lines above)",
                env.fails
            ),
        ));
    }
    println!("bootstrap: all tools present");
    println!(
        "bootstrap: put them on PATH with: export PATH=\"{}/bin:$PATH\"",
        prefix.display()
    );
    Ok(ExitCode::SUCCESS)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn sha256_of_known_input() {
        assert_eq!(
            sha256_hex(b"abc"),
            "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"
        );
    }

    #[test]
    fn typst_is_pinned_in_the_specs() {
        let s = specs();
        assert_eq!(s[0], "typst==0.15.1");
        assert!(["go-yq", "tectonic", "just", "zip", "unzip", "libxml2"]
            .iter()
            .all(|t| s.contains(&t.to_string())));
    }

    #[test]
    fn probe_lines() {
        assert_eq!(
            probe_line("jq", &Probe::Ok("jq-1.7\nmore".into()), "/x/jq"),
            "ok       jq-1.7  [/x/jq]"
        );
        assert_eq!(probe_line("jq", &Probe::Missing, ""), "MISSING  jq");
        assert_eq!(
            probe_line("jq", &Probe::Broken("boom\nx".into()), ""),
            "BROKEN   jq: version probe exited non-zero: boom"
        );
    }

    #[test]
    fn version_and_yq_flavour() {
        assert_eq!(typst_version("typst 0.15.1 (abc123)"), "0.15.1");
        assert_eq!(typst_version(""), "");
        assert!(is_mikefarah(
            "yq (https://github.com/mikefarah/yq/) version v4.44"
        ));
        assert!(!is_mikefarah("yq 3.4.1"));
    }

    #[test]
    fn finds_tools_on_the_given_path_only() {
        let t = TempDir::new("boot-test").unwrap();
        std::fs::write(t.path().join("sometool"), "").unwrap();
        let env = Env {
            path: t.path().as_os_str().to_owned(),
            fails: 0,
        };
        assert!(env.find("sometool").is_some());
        assert!(env.find("othertool").is_none());
    }
}
