class DemandReport
  # Count each person once per category, whether selected directly or through a favourite.
  def self.category_counts(confirmed: false)
    confirmation_clause = confirmed ? "AND signups.confirmed_at IS NOT NULL" : ""
    rows = ApplicationRecord.connection.select_rows(<<~SQL)
      SELECT demand.category_id, COUNT(DISTINCT demand.signup_id)
      FROM (
        SELECT category_id, waitlist_signup_id AS signup_id FROM waitlist_category_interests
        UNION
        SELECT product_categories.category_id, product_interests.waitlist_signup_id AS signup_id
        FROM product_interests
        INNER JOIN product_categories ON product_categories.product_id = product_interests.product_id
        INNER JOIN products ON products.id = product_interests.product_id
        WHERE product_interests.waitlist_signup_id IS NOT NULL AND products.launch_status <> 'rejected'
      ) AS demand
      INNER JOIN waitlist_signups AS signups ON signups.id = demand.signup_id
      WHERE signups.unsubscribed_at IS NULL #{confirmation_clause}
      GROUP BY demand.category_id
    SQL
    rows.to_h.transform_keys(&:to_i).transform_values(&:to_i)
  end
end
