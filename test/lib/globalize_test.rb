# frozen_string_literal: true

require 'test_helper'

class GlobalizeTest < Minitest::Test
  def setup
    skip if not SUPPORT_GLOBALIZE
  end

  def test_1_level_deep
    I18n.with_locale(:en) do
      assert_equal([
        { 'title' => 'What is your favorite food?' },
        { 'title' => 'Why did you purchase this product?' },
      ], Questionnaire.deep_pluck(:title))
    end

    I18n.with_locale(:'zh-TW') do
      assert_equal([
        { 'title' => '你最愛的食物為何？' },
      ], Questionnaire.deep_pluck(:title))
    end
  end

  def test_2_level_deep
    I18n.with_locale(:en) do
      assert_equal([
        {
          'name'           => 'John',
          'questionnaires' => [
            { 'title'=>'What is your favorite food?' },
            { 'title' => 'Why did you purchase this product?' },
          ],
        },
        { 'name' => 'Pearl', 'questionnaires' => [] },
        { 'name' => 'Doggy', 'questionnaires' => [] },
        { 'name' => 'Catty', 'questionnaires' => [] },
      ], User.deep_pluck(:name, 'questionnaires' => :title))
    end

    I18n.with_locale(:'zh-TW') do
      assert_equal([
        { 'name' => 'John', 'questionnaires' => [{ 'title'=>'你最愛的食物為何？' }] },
        { 'name' => 'Pearl', 'questionnaires' => [] },
        { 'name' => 'Doggy', 'questionnaires' => [] },
        { 'name' => 'Catty', 'questionnaires' => [] },
      ], User.deep_pluck(:name, 'questionnaires' => :title))
    end
  end
end
