//! `fb contribute pick [--seed N] [--kind K] [--priority P] [--offline]`: draw one open, unclaimed unit.
use super::{claimed_set, die, field, load_worklist, usage, Ctx, Net};
use crate::Res;
use serde_json::Value;
use std::process::ExitCode;

/// POSIX `cksum` of `data` (CRC-32 with polynomial 0x04C11DB7, then the length, complemented).
pub fn cksum(data: &[u8]) -> u32 {
    let step = |crc: u32, b: u8| {
        (0..8).fold(crc ^ (u32::from(b) << 24), |c, _| {
            if c & 0x8000_0000 != 0 {
                (c << 1) ^ 0x04C1_1DB7
            } else {
                c << 1
            }
        })
    };
    let crc = data.iter().fold(0, |c, &b| step(c, b));
    let mut len = data.len();
    let mut crc = crc;
    while len != 0 {
        crc = step(crc, (len & 0xff) as u8);
        len >>= 8;
    }
    !crc
}

/// A numeric seed is used as given; anything else is reduced with cksum, so a word is a stable seed too.
pub fn seed_of(s: &str) -> u64 {
    s.parse::<u64>()
        .unwrap_or_else(|_| u64::from(cksum(s.as_bytes())))
}

/// The pool to draw from: without a priority filter, only the best priority class that still has an
/// unclaimed unit; units are `(priority, id)` already sorted by id.
pub fn pool(cands: &[(String, String)], prio: &str) -> Vec<String> {
    if !prio.is_empty() {
        return cands.iter().map(|(_, id)| id.clone()).collect();
    }
    ["high", "normal", "low"]
        .iter()
        .map(|c| {
            cands
                .iter()
                .filter(|(p, _)| p == c)
                .map(|(_, id)| id.clone())
                .collect::<Vec<_>>()
        })
        .find(|p| !p.is_empty())
        .unwrap_or_default()
}

pub fn run(ctx: &Ctx, args: &[String]) -> Res<ExitCode> {
    let (mut seed, mut kind, mut prio, mut offline) = (None, String::new(), String::new(), false);
    let mut it = args.iter();
    while let Some(a) = it.next() {
        match a.as_str() {
            "--seed" => seed = Some(it.next().ok_or_else(usage)?.clone()),
            "--kind" => kind = it.next().ok_or_else(usage)?.clone(),
            "--priority" => prio = it.next().ok_or_else(usage)?.clone(),
            "--offline" => offline = true,
            _ => return Err(usage()),
        }
    }
    if !["", "new-template", "new-doctype", "add-exemplar", "deepen"].contains(&kind.as_str()) {
        return Err(die(
            "--kind must be new-template|new-doctype|add-exemplar|deepen",
        ));
    }
    if !["", "high", "normal", "low"].contains(&prio.as_str()) {
        return Err(die("--priority must be high|normal|low"));
    }
    let seed = seed.map_or_else(
        || {
            let t = std::time::SystemTime::now()
                .duration_since(std::time::UNIX_EPOCH)
                .map_or(0, |d| d.as_nanos());
            u64::from(cksum(format!("{t} {}", std::process::id()).as_bytes()))
        },
        |s| seed_of(&s),
    );
    let net = if offline { Net::Offline } else { Net::Online };
    let wl = load_worklist(ctx, net)?;
    let claimed = claimed_set(ctx, net)?;
    let mut all: Vec<&Value> = wl["units"]
        .as_array()
        .into_iter()
        .flatten()
        .filter(|u| {
            (kind.is_empty() || u["kind"] == kind.as_str())
                && (prio.is_empty() || u["priority"] == prio.as_str())
        })
        .collect();
    all.sort_by_key(|u| field(u, "id"));
    let cands: Vec<(String, String)> = all
        .iter()
        .filter(|u| !claimed.is_claimed(&field(u, "id"), &field(u, "alias")))
        .map(|u| (field(u, "priority"), field(u, "id")))
        .collect();
    let pool = pool(&cands, &prio);
    if pool.is_empty() {
        return Err(die(format!(
            "no open unclaimed units match (kind={} priority={})",
            if kind.is_empty() { "any" } else { &kind },
            if prio.is_empty() { "any" } else { &prio }
        )));
    }
    let id = &pool[(seed % pool.len() as u64) as usize];
    let u = all
        .iter()
        .find(|u| u["id"] == id.as_str())
        .copied()
        .unwrap_or(&Value::Null);
    println!("id:       {}", field(u, "id"));
    println!("kind:     {}", field(u, "kind"));
    println!("priority: {}", field(u, "priority"));
    println!(
        "court:    {}  {}",
        field(u, "alias"),
        field(u, "court_path")
    );
    println!("doctype:  {}  ({})", field(u, "doctype"), field(u, "title"));
    println!("folder:   {}", field(u, "folder"));
    println!("note:     {}", field(u, "note"));
    let extra = format!(
        "{}{}",
        if kind.is_empty() {
            String::new()
        } else {
            format!(" --kind {kind}")
        },
        if prio.is_empty() {
            String::new()
        } else {
            format!(" --priority {prio}")
        }
    );
    println!(
        "seed:     {seed}   (pool of {} unclaimed; reproduce: just contribute pick --seed {seed}{extra})",
        pool.len()
    );
    println!("next:     just contribute claim {id}   &&   just contribute brief {id}");
    Ok(ExitCode::SUCCESS)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn cksum_matches_posix() {
        assert_eq!(cksum(b"123456789"), 930_766_865);
        assert_eq!(cksum(b""), 4_294_967_295);
    }

    #[test]
    fn seeds() {
        assert_eq!(seed_of("42"), 42);
        assert_eq!(seed_of("123456789"), 123_456_789);
        assert_eq!(seed_of("abc"), u64::from(cksum(b"abc")));
    }

    fn c(v: &[(&str, &str)]) -> Vec<(String, String)> {
        v.iter()
            .map(|(p, i)| (p.to_string(), i.to_string()))
            .collect()
    }

    #[test]
    fn pool_takes_best_class_unless_filtered() {
        let cands = c(&[("low", "a"), ("normal", "b"), ("normal", "c")]);
        assert_eq!(pool(&cands, ""), ["b", "c"]);
        assert_eq!(pool(&cands, "low"), ["a", "b", "c"]);
        assert!(pool(&[], "").is_empty());
    }
}
