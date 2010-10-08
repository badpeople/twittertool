require 'test_helper'

class KeywordsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end
  
  def test_show
    get :show, :id => Keyword.first
    assert_template 'show'
  end
  
  def test_new
    get :new
    assert_template 'new'
  end
  
  def test_create_invalid
    Keyword.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end
  
  def test_create_valid
    Keyword.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to keyword_url(assigns(:keyword))
  end
  
  def test_edit
    get :edit, :id => Keyword.first
    assert_template 'edit'
  end
  
  def test_update_invalid
    Keyword.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Keyword.first
    assert_template 'edit'
  end
  
  def test_update_valid
    Keyword.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Keyword.first
    assert_redirected_to keyword_url(assigns(:keyword))
  end
  
  def test_destroy
    keyword = Keyword.first
    delete :destroy, :id => keyword
    assert_redirected_to keywords_url
    assert !Keyword.exists?(keyword.id)
  end
end
