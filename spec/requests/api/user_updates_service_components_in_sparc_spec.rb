require 'rails_helper'

RSpec.describe 'User updates Service Components in SPARC', type: :request, enqueue: false do

  describe 'full lifecycle' do

    it 'should update the Protocol', sparc_api: :get_service_components_1 do
      line_item = create(:line_item, service: create(:service_with_one_time_fee), protocol: create(:protocol), quantity_requested: 500, quantity_type: 'each')

      user_updates_service_components_in_sparc
      puts "^"*50
      puts "line_item.components.map(&:component)"
      puts line_item.components.map(&:component)
      puts "-"*50
      puts "line_item.service.components"
      puts line_item.service.components
      puts "^"*50
      expect(line_item.components.map(&:component)).to eq ['a','b','c','o']
    end
  end

  private

  def user_updates_service_components_in_sparc
    notification  = build(:notification_service_update, sparc_id: 1)
    
    puts "*"*50
    puts notification.kind
    puts "-"*50
    puts notification.action
    puts "-"*50
    puts notification.sparc_id
    puts "*"*50
    params        = {
      notification: {
        sparc_id: notification.sparc_id,
        kind: notification.kind,
        action: notification.action,
        callback_url: "http://localhost:5000/v1/services/1.json"
      }
    }

    sparc_sends_notification_post params
  end
end
