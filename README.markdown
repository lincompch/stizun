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
   (Ingram Micro, Alltron). Can be extended with your own CSV importers.
 * UUID-based invoice generator: Users don't need to remember their
   login details just to follow a link from an e-mail to their
   invoice.
 * Automatic assignment of any supplier's products to your own product
   category tree after every import. This way, a single employee
   can manage hundreds of thousands of products and tens of thousands
   of product updates per day.


It's not ready for production yet, but we're getting there!


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
