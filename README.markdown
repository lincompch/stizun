
General information
===================

Stizun is a deliberately simplistic e-commerce solution written
in Ruby on Rails.

Main features:

 * Unique shipping calculation system for stores that don't have
   their own warehouses but ship directly from suppliers to their
   customers (just-in-time). Can also calculate shipping for a mix
   of various suppliers in one order.

 * Importers for product catalog CSV files of large European distributors 
   (Ingram Micro, Alltron, jET). Can be extended with your own CSV importers.

 * UUID-based invoice generator: Users don't need to remember their
   login details just to follow a link from an e-mail to their
   invoice.

 * Automatic assignment of any supplier's products to your own product
   category tree after every import. This way, a single employee
   can manage hundreds of thousands of products and tens of thousands
   of product updates per day.

This store is used in production at http://www.lincomp.ch

The admin interface is not pretty, but it's working and is reliable. The
instance at lincomp.ch has successfully imported and handled several tens
of millions of supply item and product updates over the years.

If you want to make a prettier admin interface, please feel free.

Requirements
============

 * Ruby 1.9.3 (can't guarantee anything for jRuby or Ruby 1.9.2)
 * Debian GNU/Linux (not tested on anything else)
 * MySQL (because of Sphinx)
 * Sphinx (for fulltext search)


Installation
============

The installation is quite typical for a Rails project, but here it is
step by step:

 * Grab source code
 * Go to the directory you have the source in
 * bundle install
 * Edit config/database.yml to suit your database config
 * Edit config/stizun.yml to your liking
 * bundle exec rake db:migrate
 * Edit db/seeds.rb to your liking (change the values to something reasonable)
 * bundle exec rake db:seed
 * bundle exec rake ts:conf ts:reindex ts:start
 * bundle exec rails s
 * Go to http://localhost:3000
 * Register a new user
 * bundle exec rails c
 * u = User.first
 * u.groups << Usergroup.where(:name => 'Admin').first
 * u.save

Repeat this in your production environment (`RAILS_ENV=production`) when you're
ready to go into production mode.
 
Copryight and licensing statement
=================================

Stizun, (C) 2010 - 2012 Ramón Cahenzli

This is Free Software distributed under the terms of the Apache 2.0 license.

See the file LICENSE for the full text of the license.

It is also available on the Web: http://www.apache.org/licenses/LICENSE-2.0.txt

Licenses of included works
==========================

It is possible that this source code distribution includes code (libraries,
plugins, extensions, samples, etc.) that belong to other owners than the one
stated above. In such a case, the license included with the code in question
has precedence over the Apache license.
