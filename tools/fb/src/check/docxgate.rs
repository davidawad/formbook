//! DEF-DOCX-OPEN in `fb check --engine docx`: the .docx beside each sample's LibreOffice PDF opens (docxopen.rs).
//! Run by the driver, like TNR-EMBEDDED, so a court's own checks.yaml cannot leave it out.
use super::rows::pad14;
use super::Sample;
use crate::docxopen::{check, ID, NAME};
use crate::Res;
use std::path::Path;

/// The PASS or FAIL block for the .docx of `s` (`s.pdf` is `usage/OUTPUT-<id>.docx.pdf`); true on PASS.
pub fn run(s: &Sample) -> Res<(bool, String)> {
    let docx = s.pdf.strip_suffix(".pdf").unwrap_or(&s.pdf);
    let work = Path::new(&s.w).join("docx-open");
    let _ = std::fs::remove_dir_all(&work);
    std::fs::create_dir_all(&work).map_err(|e| super::sh::io_fail(&work.to_string_lossy(), e))?;
    let found = match Path::new(docx).is_file() {
        true => check(Path::new(docx), &work)?,
        false => vec![format!("{docx} is missing")],
    };
    let base = docx.rsplit('/').next().unwrap_or(docx);
    Ok(match found.is_empty() {
        true => (
            true,
            format!("  PASS  {} {NAME}\n          {base}: opens\n", pad14(ID)),
        ),
        false => {
            let detail: String = found.iter().map(|f| format!("          - {f}\n")).collect();
            (
                false,
                format!(
                    "  FAIL  {} {NAME}\n          measured: {base}: {} problems\n          expected: a valid zip, well-formed XML parts, every relationship id and target resolves, soffice converts it\n          fix:      docx/  (the raw OpenXML a filter writes; name only footers fb render adds, docxpass.rs)\n{detail}",
                    pad14(ID),
                    found.len()
                ),
            )
        }
    })
}
