# Writing LookML as a SQL Expert


[![Watch on YouTube](https://img.shields.io/badge/Watch_on_YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white)]()


---
### 🤝 Support
If you found this helpful, please **Subscribe** to [Cloud Wale Jiju](https://www.youtube.com/@cloudwalejijaji/videos) for more Google Cloud solutions!


### ⚠️ Disclaimer
- **This script and guide are provided for  the educational purposes to help you understand the lab services and boost your career. Before using the script, please open and review it to familiarize yourself with Google Cloud services. Ensure that you follow 'Qwiklabs' terms of service and YouTube’s community guidelines. The goal is to enhance your learning experience, not to bypass it.**

### ©Credit
- **DM for credit or removal request (no copyright intended) ©All rights and credits for the original content belong to Google Cloud [Google Cloud Skill Boost website](https://www.cloudskillsboost.google/)** 🙏

## Create View `order_items`

```bash
view: order_items {
  sql_table_name: `cloud-training-demos.thelook_ecommerce.order_items` ;;
  drill_fields: [id]

  # ---------------------------
  # PRIMARY KEY
  # ---------------------------
  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  # ---------------------------
  # DATE DIMENSION GROUPS
  # ---------------------------
  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.created_at ;;
  }

  dimension_group: delivered {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.delivered_at ;;
  }

  dimension_group: returned {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.returned_at ;;
  }

  dimension_group: shipped {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.shipped_at ;;
  }

  # ---------------------------
  # OTHER DIMENSIONS
  # ---------------------------
  dimension: inventory_item_id {
    type: number
    sql: ${TABLE}.inventory_item_id ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}.order_id ;;
  }

  dimension: product_id {
    type: number
    sql: ${TABLE}.product_id ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}.user_id ;;
  }

  dimension: sale_price {
    type: number
    sql: ${TABLE}.sale_price ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  # ---------------------------
  # MEASURES
  # ---------------------------
  measure: count {
    label: "# of Order Items"
    type: count
    drill_fields: [id]
  }

  measure: total_sale_price {
    type: sum
    sql: ${sale_price} ;;
    value_format_name: usd
  }

  measure: customer_dividends {
    description: "Customers receive 10% of their total sales as a gift card for future purchases."
    type: number
    sql: 0.1 * ${total_sale_price} ;;
    value_format_name: usd
  }
}
```

## Open:  `qwiklabs-looker.model`
```bash
explore: order_items {
  label: "Ordered Items"

  join: users {
    type: left_outer
    sql_on: ${order_items.user_id} = ${users.id} ;;
    relationship: many_to_one
  }
}
```

## Update `order_items.view`

```bash
view: order_items {
  sql_table_name: `cloud-training-demos.thelook_ecommerce.order_items` ;;
  drill_fields: [id]

  # =========================
  # PRIMARY KEY
  # =========================
  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  # =========================
  # DATE DIMENSION GROUPS
  # =========================
  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.created_at ;;
  }

  dimension_group: delivered {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.delivered_at ;;
  }

  dimension_group: returned {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.returned_at ;;
  }

  dimension_group: shipped {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.shipped_at ;;
  }

  # =========================
  # OTHER DIMENSIONS
  # =========================
  dimension: inventory_item_id {
    type: number
    sql: ${TABLE}.inventory_item_id ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}.order_id ;;
  }

  dimension: product_id {
    type: number
    sql: ${TABLE}.product_id ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}.user_id ;;
  }

  dimension: sale_price {
    type: number
    sql: ${TABLE}.sale_price ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  # =========================
  # MEASURES
  # =========================
  measure: count {
    label: "# of Order Items"
    type: count
    drill_fields: [id]
  }

  measure: total_sale_price {
    type: sum
    sql: ${sale_price} ;;
    value_format_name: usd
  }

  measure: customer_dividends {
    description: "Customers receive 10% of their total sales as a gift card for future purchases."
    type: number
    sql: 0.1 * ${total_sale_price} ;;
    value_format_name: usd
  }
}
```

## Create View `top_100_users`

```bash
view: top_100_users {
  derived_table: {
    explore_source: order_items {
      column: user_id {}
      column: customer_dividends {}
      column: total_sale_price {}
      column: email { field: users.email }
    }
  }

  dimension: user_id {
    primary_key: yes
    type: number
  }

  dimension: customer_dividends {
    value_format: "$#,##0.00"
    type: number
  }

  dimension: total_sale_price {
    value_format: "$#,##0.00"
    type: number
  }

  dimension: email {
    type: string
  }
}
```

