# frozen_string_literal: true

# Expose the build's git commit SHA to Liquid as `site.commit_hash`.
#
# The footer uses it to link each page to its source file on GitHub at the exact
# revision the site was built from ("Improve this page @ <short sha>").
#
# On the GitHub Actions deploy, GITHUB_SHA is the commit that triggered the run.
# For a local full build (`make serve`) we fall back to `git rev-parse HEAD`.
# Runs only under a full (non-safe) Jekyll build, same as _plugins/typography.rb.
Jekyll::Hooks.register :site, :after_init do |site|
  sha = ENV["GITHUB_SHA"]
  sha = `git rev-parse HEAD 2>/dev/null`.strip if sha.nil? || sha.empty?
  site.config["commit_hash"] = sha unless sha.empty?
end
