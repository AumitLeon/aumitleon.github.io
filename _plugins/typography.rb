# frozen_string_literal: true

# Build-time typography pass: Tufte-style sidenotes with zero runtime JS.
#
# Kramdown renders `[^1]` footnotes as a superscript reference in the text plus
# an endnote list at the bottom of the page. This pass leaves both in place and
# *additionally* plants an inline copy of each note as a <span class="sidenote">
# right after the sentence that raised it. The stylesheet then shows exactly one
# copy per screen width (see the sidenote rules in assets/css/main.css):
#
#   * wide screens  -> float the inline copy into the right margin; hide the
#                      bottom endnote list.
#   * narrow screens -> hide the inline copy; the endnote list stays at the
#                      bottom, i.e. footnotes behave the ordinary way.
#
# Because the hidden copy is `display:none` (out of the a11y tree as well), a
# screen reader always encounters exactly the visible one, never both.
#
# It runs only under a full (non-safe) Jekyll build -- i.e. `make serve`
# locally and the GitHub Actions deploy. GitHub Pages' native build ignores
# _plugins/ entirely, which is why this repo deploys via Actions.
#
# Adapted from Farid Zakaria's fzakaria.com (_plugins/typography.rb), trimmed
# to just the sidenote pass.
module Typography
  # <div class="footnotes" role="doc-endnotes"><ol> ... </ol></div>
  FOOTNOTES = %r{<div class="footnotes"[^>]*>\s*<ol>(.*?)</ol>\s*</div>}m

  # <li id="fn:1"> ... </li>, matched non-greedily so a note containing its own
  # nested list still comes out whole.
  NOTE = %r{\A<li id="fn:([^"]+)"[^>]*>(.*)</li>\s*\z}m

  # The "↩" backlink kramdown appends; pointless once the note is in the margin.
  BACKLINK = %r{\s*<a href="\#fnref:[^"]*"[^>]*class="reversefootnote"[^>]*>.*?</a>}m

  # <sup id="fnref:1"><a href="#fn:1" ...>1</a></sup>
  REF = %r{<sup id="fnref:([^"]+?)(?::\d+)?"[^>]*>\s*<a href="\#fn:[^"]*"[^>]*>(.*?)</a>\s*</sup>}m

  # A sidenote is a <span> living inside the referencing <p>, so its body may
  # only contain phrasing content. A stray block element would make the parser
  # close the paragraph early and spill the note into the main column, so any
  # note containing one disqualifies the whole page (it falls back to endnotes).
  BLOCK_ELEMENT = %r{<(?:div|ul|ol|li|pre|table|blockquote|figure|h[1-6])[\s>]}i

  module_function

  def apply(html)
    sidenotes(html)
  end

  # Plant an inline copy of each footnote body immediately after its reference
  # marker, leaving kramdown's marker and endnote list intact.
  #
  # All-or-nothing on purpose: if any note cannot be paired with a reference the
  # page is left completely untouched, so it just renders as ordinary endnotes
  # at both widths rather than showing some notes twice or dropping them.
  def sidenotes(html)
    match = html.match(FOOTNOTES)
    return html if match.nil?

    notes = parse_notes(match[1])
    return html if notes.empty?

    placed = {}
    rewritten = html.gsub(REF) do
      whole = Regexp.last_match(0)
      id = Regexp.last_match(1)
      label = Regexp.last_match(2)
      body = notes[id]

      if body.nil? || placed.key?(id)
        # Unknown ref, or a repeat reference: leave the marker, add no copy.
        whole
      else
        placed[id] = true
        whole + %(<span class="sidenote"><span class="sn-num">#{label}</span>#{body}</span>)
      end
    end

    # If any note went unplaced, discard the whole rewrite and fall back to
    # plain endnotes.
    return html unless placed.size == notes.size

    # Tag the endnote list so the stylesheet can hide it on wide screens (where
    # the inline copies show in the margin) while keeping it for narrow screens.
    rewritten.sub('<div class="footnotes', '<div class="footnotes has-sidenotes')
  end

  def parse_notes(list)
    notes = {}

    list.split(/(?=<li id="fn:)/).each do |chunk|
      chunk = chunk.strip
      next if chunk.empty?

      m = chunk.match(NOTE)
      next if m.nil?

      body = m[2].gsub(BACKLINK, "").strip
      return {} if body.match?(BLOCK_ELEMENT)

      notes[m[1]] = phrasing(body)
    end

    notes
  end

  # Paragraphs become spans so the note stays legal inside its host paragraph.
  def phrasing(body)
    body.gsub(/<p(\s[^>]*)?>/) { %(<span class="sn-p"#{Regexp.last_match(1)}>) }
        .gsub("</p>", "</span>")
  end
end

Jekyll::Hooks.register %i[documents pages], :post_render do |doc|
  next unless doc.output_ext == ".html"

  doc.output = Typography.apply(doc.output)
end
