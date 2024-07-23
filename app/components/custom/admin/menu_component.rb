load Rails.root.join("app", "components", "admin", "menu_component.rb")

class Admin::MenuComponent
  def maps_link
    [
      t("admin.menu.maps"),
      admin_maps_path,
      maps?
    ]
  end
end
