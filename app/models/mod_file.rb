class ModFile < ActiveRecord::Base
  belongs_to :mod_version

  has_attached_file :attachment
  validates_attachment_content_type :attachment,
                                    :content_type => ['application/zip', 'application/octet-stream/']


  validates :mod_version, presence: true

  def delegated_name
    name || mod_version.number
  end
end
