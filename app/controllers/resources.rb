Ladder.controllers :resources do

#  provides :json, :xml

  get :index, :with => :id do
    @resource = Resource.find(params[:id])
#    case content_type
#      when :json, :xml then @resource.send("to_#{content_type}")
#      when :html then render 'resources/index'
#    end
    render 'resources/index'
  end
end
