//! Completion tracker: the logic of tools/tracker.bend. `compute` turns the two manifests written
//! by fb manifest into the five sections bend printed (each line followed by "\n").
mod parse;
mod render;

/// The sections of the tracker output, each the text below its `=== <name>` header.
#[derive(Clone, Debug, Default, PartialEq, Eq)]
pub struct Sections {
    pub summary: String,
    pub status: String,
    pub rows: String,
    pub dsummary: String,
    pub doctypes: String,
    pub docrows: String,
}

fn text(ls: Vec<String>) -> String {
    ls.into_iter().map(|l| l + "\n").collect()
}

/// `manifest`: lines alias|group|level|name|path|manual|flags; `doctypes`: lines
/// alias|group|doctype|path|flags (see fb manifest).
pub fn compute(manifest: &str, doctypes: &str) -> Sections {
    let ds = parse::doctypes(doctypes);
    let cs = parse::with_engines(parse::courts(manifest), &ds);
    Sections {
        summary: text(render::summary(&cs)),
        status: text(render::status(&cs)),
        rows: text(render::rows(&cs)),
        dsummary: text(render::dsummary(&ds)),
        doctypes: text(render::doctypes(&ds)),
        docrows: text(render::docrows(&ds)),
    }
}

#[cfg(test)]
mod tests;
