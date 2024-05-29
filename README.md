[![CircleCI](https://circleci.com/gh/KPB-US/badgeulator.svg?style=svg)](https://circleci.com/gh/KPB-US/badgeulator)
[![Build Status](https://travis-ci.org/KPB-US/badgeulator.svg?branch=master)](https://travis-ci.org/KPB-US/badgeulator)
[![Code Climate](https://codeclimate.com/github/KPB-US/badgeulator/badges/gpa.svg)](https://codeclimate.com/github/KPB-US/badgeulator) [![Coverage](https://codeclimate.com/github/KPB-US/badgeulator/badges/coverage.svg)](https://codeclimate.com/github/KPB-US/badgeulator)

A system to keep track of and print employee identification cards.  

<table>
<tr>
<td align="center"><img src="https://raw.githubusercontent.com/KPB-US/badgeulator/master/test/samples/Selection_144.png" alt="Info &amp; Cropping"><br/><em>Info &amp; Cropping</em></td>
<td align="center"><img src="https://raw.githubusercontent.com/KPB-US/badgeulator/master/test/samples/Selection_145.png" alt="Preview"><br/><em>Preview</em></td>
<td align="center"><img src="https://raw.githubusercontent.com/KPB-US/badgeulator/master/test/samples/Selection_146.png" alt="Design"><br/><em>Design</em></td>
</tr>
</table>

# FEATURES

- admin and user roles, admin can maintain users and delete data, devise ldap authentication by default
- user-defined badge layouts
- lookup employee data from external source (default is active directory) or simply fill in fields
- updates thumbnailPhoto in active directory
- takes picture via webcam

It does not do any encoding, though adding a barcode would be simple since prawn is used to generate the badge.

# PRAWN NOTES

https://www.rubydoc.info/github/sandal/prawn/toplevel

{cursor} = The current y drawing position relative to the innermost bounding box, or to the page margins at the top level.

# CONFIGURATION

- If using active directory, you'll need to configure the ldap.yml for your connection information.
- Database connection information goes in the database.yml.
- .env (or your environment) needs the following:
  - USE_LDAP=true - to lookup employee information based on the employee id via an LDAP query
  - ALLOW_EDIT=true - to allow employee fields (for the badge) to be edited
  - PRINTER=it-riopro - specify the name of the cups printer to use
  - PRINTER_OPTIONS="options" - specify any options you want to pass on to the printer driver
- Devise needs to be configured in the initializer
- Errbit (airbrake) needs to be configured in the initializer
- Make sure you have pdftoppm installed.  It's in the poppler-utils apt-get package.  This is used for
converting the pdf to images for previews and does a much crisper job than imagemagick.

# DEPLOYMENT

Deploy with capistrano.  `cap staging deploy`
If you get a weird error from passenger about a binary ruby version, then check to make sure your database.yml and ldap.yml files are set up properly.

If Chrome says that you've disallowed access to your camera, it might be because you need to have SSL enabled for the site and it will only work under a secure connection to the server.

You may choose to run `rake db:seed` to populate the sample badge designs.

## Changing the LDAP query

It currently looks up the employee information based on the employeeId attribute, you could change this to something else in badge_controller#lookup or in the badge model's lookup_employee method if more complex query is needed.

# TESTING

May need to add a _nowhere_ printer.  

```
lpadmin -p nowhere -E -v file:/dev/null
```

# ATTRIBUTION

Badger image taken from photo by [James Perdue](https://www.flickr.com/photos/rvguy/3860650150), via [CC2 license] (https://creativecommons.org/licenses/by/2.0/).

