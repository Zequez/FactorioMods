ActiveAdmin.register GameVersion do
  permit_params :number, :released_at

  controller do
    def create
      create! { url_for [:admin, GameVersion] }
    end

    def update
      update! { url_for [:admin, GameVersion] }
    end
  end

  form do |f|
    f.inputs do
      f.input :number
      f.input :released_at, as: :datepicker, input_html: { value: f.object.released_at.strftime('%Y-%m-%d') }
    end

    f.actions
  end
end
