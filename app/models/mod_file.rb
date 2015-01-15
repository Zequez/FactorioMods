class ModFile < ActiveRecord::Base
  belongs_to :mod_version
  belongs_to :mod

  has_attached_file :attachment
  validates_attachment_content_type :attachment,
                                    :content_type => ['application/zip', 'application/x-zip-compressed', 'application/octet-stream/']

  validates :attachment, presence: true

  before_save do
    self.mod = mod_version.mod if mod_version
  end

  def delegated_name
    name || (mod_version ? mod_version.number : nil)
  end
end
