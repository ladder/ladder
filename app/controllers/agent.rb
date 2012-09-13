Ladder.controllers :agent do

#  provides :json, :xml

  get :index, :with => :id do
    @agent = Agent.find(params[:id])
#    case content_type
#      when :json, :xml then @resource.send("to_#{content_type}")
#      when :html then render 'resources/index'
#    end
    render 'agent/index'
  end
end
