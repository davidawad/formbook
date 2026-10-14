# Tahoma substitute: findings (fb-595.7.3)

Recommendation: do not vendor a Tahoma stand-in; no free font found is metric-compatible with Tahoma.

| Option | Licence | Metric-compatible with Tahoma | Styles | Verdict |
|---|---|---|---|---|
| Wine Tahoma (wine/fonts/tahoma.ttf, tahomabd.ttf) | LGPL 2.1+ (name table); derived from Bitstream Vera Sans, renamed per the Vera licence | No. Its own copyright field says "Based on Bitstream Vera Sans"; a visual look-alike only | Regular, Bold (no italics) | Redistributable, but wrong metrics and 2 of 4 styles |
| DejaVu Sans | Bitstream Vera licence (free redistribution) | No (Vera/DejaVu are wider than Tahoma) | 4 styles | Redistributable visual stand-in only; would reflow Tahoma text |
| Real Tahoma | Microsoft proprietary | Yes | n/a | Cannot be vendored |

Why not vendor: the other families exist so line breaks and page counts match the named face. Wine Tahoma and DejaVu Sans do not, so a Tahoma-named rule would silently paginate differently while looking compliant. If a template must use Tahoma, either (a) require a licensed Tahoma at render time (not hermetic), or (b) accept DejaVu Sans as a labelled non-metric fallback. That is a maintainer policy call.

Sources:
- https://github.com/wine-mirror/wine/blob/master/fonts/tahoma.sfd (copyright and LGPL text in name table)
- https://github.com/wine-mirror/wine/tree/master/fonts
- https://dejavu-fonts.github.io/License.html

## Decision (team lead, fb-595.7.3 follow-up)

Use DejaVu Sans as a labelled, non-metric visual fallback for Tahoma. The repo must render with vendored fonts only, so it cannot require a licensed Tahoma. Vendored in `fonts/dejavu-sans/` (see its `README.md`, `SOURCE.md`). Pagination may differ from real Tahoma.
