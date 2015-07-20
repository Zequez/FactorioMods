class ModFile < ActiveRecord::Base
  belongs_to :mod_version
  belongs_to :mod

  has_attached_file :attachment
  validates_attachment_content_type :attachment,
                                    :content_type => ['application/zip', 'application/x-zip-compressed', 'application/octet-stream']

  validates :attachment, presence: { :if => 'download_url.blank?' }
  validates_attachment_size :attachment, less_than: 20.megabytes
  validates :download_url, allow_blank: { :if => 'attachment.present?' },
                           format: { with: /\Ahttps?:\/\/.*\Z/ }

  before_save do
    self.mod = mod_version.mod if mod_version
  end

  def delegated_name
    name || (mod_version ? mod_version.number : nil)
  end

  def available_url
    download_url.presence || (attachment.present? ? attachment.url : '')
  end
end
