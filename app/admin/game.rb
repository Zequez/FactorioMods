ActiveAdmin.register Game do
  permit_params :name, versions_attributes: [:id, :number, :released_at, :sort_order, :group_id, :is_group, :_destroy]

  controller do
    def index
      if Game.all.size == 0
        redirect_to new_admin_game_url
      else
        redirect_to edit_admin_game_url(Game.first)
      end
    end

    def show
      redirect_to edit_admin_game_url(params[:id])
    end

    # def update
    #   resource
    #   resource.assign_attributes permitted_params[:game]

    #   resource.versions.each do |v|
    #     p '----'
    #     p v.id
    #     p v.id_was
    #     if v.changed?
    #       p v.new_record?
    #     end
    #     v.save if v.is_group? and v.changed?
    #   end

    #   options = {}
    #   if resource.save
    #     options[:location] ||= smart_resource_url
    #   end

    #   respond_with_dual_blocks(resource, options)
    # end
  end

  form do |f|
    f.inputs :name
    f.actions
    f.inputs do
      f.has_many :versions, allow_destroy: true, new_record: true, sortable: :sort_order do |a|
        a.input :number, placeholder: 'Number'
        a.input :released_at, as: :datepicker, placeholder: 'Released at',
                              input_html: { value: (a.object.released_at.strftime('%Y-%m-%d') if a.object.released_at) }
      end
    end

    f.actions
  end
end
