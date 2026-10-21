//! Unicode normalization shared by extracted and authored text comparisons.
use unicode_normalization::UnicodeNormalization;

/// Canonically compose a string before comparing text from different PDF extractors.
pub fn nfc(text: &str) -> String {
    text.nfc().collect()
}

#[cfg(test)]
mod tests {
    use super::nfc;

    #[test]
    fn composes_greek_question_mark_to_semicolon() {
        assert_eq!(nfc("citation\u{037e}"), "citation;");
        assert_eq!(nfc("citation;"), "citation;");
    }

    #[test]
    fn composes_canonical_sequences_without_changing_other_text() {
        assert_eq!(nfc("Cafe\u{0301};"), "Café;");
        assert_eq!(nfc("plain text"), "plain text");
    }
}
