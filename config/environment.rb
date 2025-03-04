# frozen_string_literal: true

require 'sqlite3'
require_relative '../lib/dog'

DB = { conn: SQLite3::Database.new('db/dogs.db') }.freeze
