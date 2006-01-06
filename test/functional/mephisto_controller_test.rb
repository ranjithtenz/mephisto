require File.dirname(__FILE__) + '/../test_helper'
require 'mephisto_controller'

# Re-raise errors caught by the controller.
class MephistoController; def rescue_action(e) raise e end; end

class MephistoControllerTest < Test::Unit::TestCase
  fixtures :articles, :tags, :taggings, :templates

  def setup
    @controller = MephistoController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_routing
    with_options :controller => 'mephisto' do |test|
      test.assert_routing '',               :action => 'list', :tags => []
      test.assert_routing 'about',          :action => 'list', :tags => ['about']
      test.assert_routing 'search/foo',     :action => 'search', :q => 'foo'
      test.assert_routing '2006',           :action => 'yearly',  :year => '2006'
      test.assert_routing '2006/01',        :action => 'monthly', :year => '2006', :month => '01'
      test.assert_routing '2006/01/01',     :action => 'daily',   :year => '2006', :month => '01', :day => '01'
      test.assert_routing '2006/01/01/foo', :action => 'show',    :year => '2006', :month => '01', :day => '01', :permalink => 'foo'
    end
  end

  def test_list_by_tags
    get :list, :tags => []
    assert_equal tags(:home), assigns(:tag)
    assert_equal [articles(:welcome).to_liquid, articles(:another).to_liquid], assigns(:articles)
    get :list, :tags => %w(about)
    assert_equal tags(:about), assigns(:tag)
    assert_equal [articles(:welcome).to_liquid], assigns(:articles)
  end

  def test_should_render_liquid_templates
    get :list, :tags => []
    assert_tag :tag => 'h1', :content => 'This is the layout'
    assert_tag :tag => 'p',  :content => 'home'
    get :list, :tags => %w(about)
    assert_tag :tag => 'p',  :content => 'tag'
  end

  def test_should_search_entries
    get :search, :q => 'another'
    assert_equal [articles(:another).to_liquid], assigns(:articles)
  end

  def test_should_show_entry
    date = 3.days.ago
    get :show, :year => date.year, :month => date.month, :day => date.day, :permalink => 'welcome_to_mephisto'
    assert_equal articles(:welcome).to_liquid['id'], assigns(:article)['id']
    assert_tag :tag => 'a', :attributes => { :href => articles(:welcome).full_permalink }, :content => articles(:welcome).title
  end

  def test_should_show_daily_entries
    date = 3.days.ago.monday
    get :daily, :year => date.year, :month => date.month, :day => date.day
    
  end
end