require 'test_helper'

class MimicsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end
  
  def test_show
    get :show, :id => Mimic.first
    assert_template 'show'
  end
  
  def test_new
    get :new
    assert_template 'new'
  end
  
  def test_create_invalid
    Mimic.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end
  
  def test_create_valid
    Mimic.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to mimic_url(assigns(:mimic))
  end
  
  def test_edit
    get :edit, :id => Mimic.first
    assert_template 'edit'
  end
  
  def test_update_invalid
    Mimic.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Mimic.first
    assert_template 'edit'
  end
  
  def test_update_valid
    Mimic.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Mimic.first
    assert_redirected_to mimic_url(assigns(:mimic))
  end
  
  def test_destroy
    mimic = Mimic.first
    delete :destroy, :id => mimic
    assert_redirected_to mimics_url
    assert !Mimic.exists?(mimic.id)
  end
end
