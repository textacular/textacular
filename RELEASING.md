# Releasing

If you want to push a new version of this gem, do this:

1. Ideally, every Pull Request should already have included an addition to the
   `CHANGELOG.md` file summarizing the changes and crediting the author(s). It
   doesn't hurt to review this to see if anything needs adding.
1. Commit any changes you make.
1. Go into version.rb and bump the version number
   [as appopriate](http://semver.org/).
1. Go into `CHANGELOG.md` and change the "Unlreleased" heading to match the new
   version number.
1. Commit these changes with a message like, "Minor version bump," or similar.
1. Run `rake release`.
1. High five someone nearby.
