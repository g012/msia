class CreateCatalogueAndWaitlist < ActiveRecord::Migration[8.1]
  def change
    create_table :brands do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :official_url
      t.timestamps
    end
    add_index :brands, :slug, unique: true
    create_table :suppliers do |t|
      t.string :name, null: false
      t.string :official_url
      t.text :notes
      t.timestamps
    end
    create_table :categories do |t|
      t.string :slug, null: false
      t.string :name_fr, null: false
      t.string :name_en, null: false
      t.string :illustration, default: "noodles"
      t.timestamps
    end
    add_index :categories, :slug, unique: true
    create_table :products do |t|
      t.references :brand, null: false, foreign_key: true
      t.references :supplier, foreign_key: true
      t.string :name, null: false
      t.string :slug, null: false
      t.string :sku
      t.string :net_weight
      t.string :pack_size
      t.string :manufacturer
      t.string :country_of_origin
      t.text :ingredients
      t.text :allergens
      t.text :nutrition
      t.text :preparation
      t.string :shelf_life
      t.boolean :vegetarian
      t.boolean :contains_animal_products
      t.boolean :spicy
      t.string :dietary_evidence
      t.string :halal_status, null: false, default: "unknown"
      t.string :eu_compliance_status, null: false, default: "unknown"
      t.string :launch_status, null: false, default: "researching"
      t.string :official_source_url
      t.string :illustration, default: "noodles"
      t.boolean :featured, default: false, null: false
      t.boolean :selected_for_first_import, default: false, null: false
      t.timestamps
    end
    add_index :products, :slug, unique: true
    add_check_constraint :products, "launch_status IN ('researching','candidate','planned','coming_soon','available','rejected')", name: "product_launch_status"
    create_table :product_translations do |t|
      t.references :product, null: false, foreign_key: true
      t.string :locale, null: false
      t.string :name, null: false
      t.text :short_description
      t.text :description
      t.text :origin
      t.text :ingredients
      t.text :allergens
      t.text :nutrition
      t.text :preparation
      t.boolean :regulated_reviewed, null: false, default: false
      t.datetime :regulated_reviewed_at
      t.timestamps
    end
    add_index :product_translations, [ :product_id, :locale ], unique: true
    create_table :product_categories do |t|
      t.references :product, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
    end
    add_index :product_categories, [ :product_id, :category_id ], unique: true
    create_table :product_sources do |t|
      t.references :product, null: false, foreign_key: true
      t.string :source_name, null: false
      t.string :url, null: false
      t.string :image_url
      t.string :image_rights_status, null: false, default: "permission_required"
      t.text :confirmed_facts
      t.text :unknown_facts
      t.datetime :checked_at
      t.timestamps
    end
    create_table :waitlist_signups do |t|
      t.string :email, null: false
      t.string :country, null: false
      t.string :locale, null: false, default: "fr"
      t.string :first_name
      t.string :postcode
      t.string :connection_to_malaysia
      t.text :import_wish
      t.datetime :consented_at, null: false
      t.string :consent_version, null: false, default: "launch-v1"
      t.datetime :confirmed_at
      t.datetime :unsubscribed_at
      t.string :utm_source
      t.string :utm_medium
      t.string :utm_campaign
      t.string :utm_content
      t.string :landing_page
      t.timestamps
    end
    add_index :waitlist_signups, :email, unique: true
    add_check_constraint :waitlist_signups, "email = lower(btrim(email))", name: "normalized_waitlist_email"
    create_table :waitlist_category_interests do |t|
      t.references :waitlist_signup, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
    end
    add_index :waitlist_category_interests, [ :waitlist_signup_id, :category_id ], unique: true, name: "unique_waitlist_category"
    create_table :product_interests do |t|
      t.references :product, null: false, foreign_key: true
      t.references :waitlist_signup, foreign_key: true
      t.string :visitor_key, null: false
      t.timestamps
    end
    add_index :product_interests, [ :product_id, :visitor_key ], unique: true
    create_table :page_metrics do |t|
      t.date :day, null: false
      t.string :path, null: false
      t.integer :views, null: false, default: 0
    end
    add_index :page_metrics, [ :day, :path ], unique: true
  end
end
