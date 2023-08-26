# frozen_string_literal: true

require 'test_helper'

class DeepPluckPrimaryKeyTest < Minitest::Test
  def setup
  end

  def test_species
    assert_equal [
      { 'name' => 'John', 'species' => [{ 'name' => 'Bat' }, { 'name' => 'bat' }, { 'name' => 'batmen' }] },
      { 'name' => 'Pearl', 'species' => [{ 'name' => 'Bat' }, { 'name' => 'bat' }, { 'name' => 'batmen' }] },
      { 'name' => 'Doggy', 'species' => [{ 'name' => 'Rat' }, { 'name' => 'rat' }] },
    ], User.where(name: %w[John Pearl Doggy]).deep_pluck(:name, 'species' => :name)
  end

  def test_primary_species_with_null_value
    assert_equal [
      { 'name' => 'John', 'primary_species' => { 'name' => 'Bat' }},
      { 'name' => 'Doggy', 'primary_species' => { 'name' => 'Rat' }},
      { 'name' => 'Catty', 'primary_species' => nil },
    ], User.where(name: %w[John Doggy Catty]).deep_pluck(:name, 'primary_species' => :name)
  end

  def test_primary_species_with_duplicate_value
    assert_equal [
      { 'name' => 'John', 'primary_species' => { 'name' => 'Bat' }},
      { 'name' => 'Pearl', 'primary_species' => { 'name' => 'Bat' } },
      { 'name' => 'Doggy', 'primary_species' => { 'name' => 'Rat' }},
    ], User.where(name: %w[John Pearl Doggy]).deep_pluck(:name, 'primary_species' => :name)
  end

  def test_species_on_model
    user = User.where(name: 'John').first

    expected = { 'name' => 'John', 'species' => [{ 'name' => 'Bat' }, { 'name' => 'bat' }, { 'name' => 'batmen' }] }
    assert_equal expected, user.deep_pluck(:name, 'species' => :name)
  end

  def test_primary_species_on_model
    user = User.where(name: 'John').first

    expected = { 'name' => 'John', 'primary_species' => { 'name' => 'Bat' }}
    assert_equal expected, user.deep_pluck(:name, 'primary_species' => :name)
  end
end
