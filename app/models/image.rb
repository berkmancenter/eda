# == Schema Information
#
# Table name: images
#
#  id          :integer          not null, primary key
#  url         :text
#  metadata    :text
#  credits     :text
#  full_width  :integer
#  full_height :integer
#  web_width   :integer
#  web_height  :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Image < ActiveRecord::Base
    has_many :sets, class_name: 'ImageSet'
    attr_accessible :credits, :url, :metadata, :web_width, :web_height, :title
    serialize :metadata
end
