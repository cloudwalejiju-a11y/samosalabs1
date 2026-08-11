<div align="center" style="padding: 25px; background: #f2f2f2; border-radius: 15px; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; box-shadow: 0px 0px 10px rgba(0,0,0,0.1);">

<h1 style="color: #2F80ED;">🚀 Model dimensions and measures using LookML </h1>


<br/>

<a href="https://www.cloudskillsboost.google/focuses/124845?parent=catalog" target="_blank" style="margin: 10px;">
  <img src="https://img.shields.io/badge/Access_Lab-4285F4?style=for-the-badge&logo=googlecloud&logoColor=white" alt="Access Lab">
</a>

<a href="" target="_blank" style="margin: 10px;">
  <img src="https://img.shields.io/badge/Watch_Solution_Video-FF0000?style=for-the-badge&logo=youtube&logoColor=white" alt="Watch Solution Video">
</a>

</div>

<div style="padding: 25px; background: #fff8e1; border-radius: 15px; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; color: #333; box-shadow: 0px 0px 10px rgba(0,0,0,0.1);">

<h2 style="color: #E65100;">⚠️ Disclaimer:</h2>

<p style="font-size: 16px;">
This script and guide are provided for educational purposes to help you understand the lab process.  
Please open and review the script to understand each step.  
Make sure to follow Qwiklabs' Terms of Service and YouTube’s Community Guidelines.  
The goal is to enhance your learning experience — not bypass it.
</p>

</div>

<br/>

<div style="padding: 25px; background: #f0f8ff; border-radius: 15px; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; color: #333; box-shadow: 0px 0px 10px rgba(0,0,0,0.1);">

<h2 style="color: #2F80ED;">🌐 Quick Start Guide:</h2>

### First, on the bottom left of the Looker User Interface, click the toggle button to enter Development mode.
![Alt text](https://cdn.qwiklabs.com/uUCbNuedSCOYQmL%2BIubjqvusmGAeS7Wjj3f6xByL174%3D)


## 📁 manifest.lkml

```lookml
project_name: "dimensions_and_measures"

constant: CONNECTION_NAME {
  value: "bigquery_public_data_looker"
  export: override_required
}

constant: DATASET {
  value: "cloud-training-demos.thelook_gcda"
  export: override_required
}
```

---

## 📁 dimensions_and_measures.model

```lookml
connection: "bigquery_public_data_looker"

include: "/views/*.view.lkml"

explore: order_items {
  join: users {
    relationship: many_to_one
    sql_on: ${users.id} = ${order_items.user_id} ;;
  }
}

explore: +order_items {
  query: subscribe_to_Drabhishek {
    dimensions: [created_day_of_week]
    measures: [total_revenue]
    filters: [order_items.created_date: "2022"]
  }
}
```

---

## ✅ Task 3: Create a View

### Step-by-step Instructions

1. In the **custom DB field**, type:
   ```
   cloud-training-demos
   ```
   Then press **ENTER**.

2. In the **left panel**, locate the **`thelook_gcda`** dataset.

3. Click the **drop-down arrow** next to `thelook_gcda` to expand and view available tables.

4. **Select the following tables** by checking the box next to each one:

   - `distribution_centers`
   - `inventory_items`
   - `order_items`
   - `products`
   - `users`

5. In the file list, click on:
   ```
   views/order_items.view.lkml
   ```

   This opens the `order_items.view` file for further editing.




---

## 📁 distribution_centers.view

```lookml
view: distribution_centers {
  sql_table_name: `cloud-training-demos.thelook_gcda.distribution_centers`
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: latitude {
    type: number
    sql: ${TABLE}.latitude ;;
  }

  dimension: longitude {
    type: number
    sql: ${TABLE}.longitude ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
  }

  measure: count {
    type: count
    drill_fields: [id, name, products.count]
  }
}

```

---

## 📁 inventory_items.view

```lookml
view: inventory_items {
  sql_table_name: `cloud-training-demos.thelook_gcda.inventory_items`
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: cost {
    type: number
    sql: ${TABLE}.cost ;;
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.created_at ;;
  }

  dimension: product_brand {
    type: string
    sql: ${TABLE}.product_brand ;;
  }

  dimension: product_category {
    type: string
    sql: ${TABLE}.product_category ;;
  }

  dimension: product_department {
    type: string
    sql: ${TABLE}.product_department ;;
  }

  dimension: product_distribution_center_id {
    type: number
    sql: ${TABLE}.product_distribution_center_id ;;
  }

  dimension: product_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.product_id ;;
  }

  dimension: product_name {
    type: string
    sql: ${TABLE}.product_name ;;
  }

  dimension: product_retail_price {
    type: number
    sql: ${TABLE}.product_retail_price ;;
  }

  dimension: product_sku {
    type: string
    sql: ${TABLE}.product_sku ;;
  }

  dimension_group: sold {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.sold_at ;;
  }

  measure: count {
    type: count
    drill_fields: [id, product_name, products.name, products.id, order_items.count]
  }
}
```

---

## 📁 order_items.view

```lookml
view: order_items {
  sql_table_name: `cloud-training-demos.thelook_gcda.order_items`
    ;;
  drill_fields: [created_date,sale_price,users.user_name]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year,
      day_of_week,
     hour_of_day
    ]
    sql: ${TABLE}.created_at ;;
  }

  dimension_group: delivered {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.delivered_at ;;
  }

  dimension: inventory_item_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.inventory_item_id ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}.order_id ;;
  }

  dimension: product_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.product_id ;;
  }

  dimension_group: returned {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.returned_at ;;
  }

  dimension: sale_price {
    type: number
    sql: ${TABLE}.sale_price ;;
  }

  dimension_group: shipped {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.shipped_at ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension: user_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.user_id ;;
  }

  measure: total_revenue  {
    type: sum
    sql: ${sale_price} ;;
  }

  measure: revenue_per_user {
    type: number
    sql: total_revenue / total_users ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      id,
      users.last_name,
      users.id,
      users.first_name,
      inventory_items.id,
      inventory_items.product_name,
      products.name,
      products.id
    ]
  }
}

```

---

## 📁 products.view

```lookml
view: products {
  sql_table_name: `cloud-training-demos.thelook_gcda.products`
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: brand {
    type: string
    sql: ${TABLE}.brand ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}.category ;;
  }

  dimension: cost {
    type: number
    sql: ${TABLE}.cost ;;
  }

  dimension: department {
    type: string
    sql: ${TABLE}.department ;;
  }

  dimension: distribution_center_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.distribution_center_id ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: retail_price {
    type: number
    sql: ${TABLE}.retail_price ;;
  }

  dimension: segment {
    type: string
    sql: ${TABLE}.segment ;;
  }

  dimension: sku {
    type: string
    sql: ${TABLE}.sku ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      id,
      name,
      distribution_centers.name,
      distribution_centers.id,
      inventory_items.count,
      order_items.count
    ]
  }
}

```

---

## 📁 users.view

```lookml
view: users {
  sql_table_name: `cloud-training-demos.thelook_gcda.users`
    ;;
  drill_fields: [id]

  dimension: full_name {
    type: string
    description: "First and last name of user"
    sql: CONCAT(${TABLE}.first_name, " ", ${TABLE}.last_name) ;;
  }

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: age {
    type: number
    sql: ${TABLE}.age ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}.city ;;
  }

  dimension: country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}.country ;;
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.created_at ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}.email ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}.first_name ;;
  }

  dimension: gender {
    type: string
    sql: ${TABLE}.gender ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}.last_name ;;
  }

  dimension: latitude {
    type: number
    sql: ${TABLE}.latitude ;;
  }

  dimension: longitude {
    type: number
    sql: ${TABLE}.longitude ;;
  }

  dimension: postal_code {
    type: string
    sql: ${TABLE}.postal_code ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}.state ;;
  }

  dimension: street_address {
    type: string
    sql: ${TABLE}.street_address ;;
  }

  dimension: traffic_source {
    type: string
    sql: ${TABLE}.traffic_source ;;
  }

  measure: total_users {
    type: count_distinct
    sql: ${TABLE}.id ;;
  }

  measure: count {
    type: count
    drill_fields: [id, last_name, first_name, order_items.count]
  }
}

```





<div align="left" style="padding: 25px; background: linear-gradient(135deg, #00C9FF, #92FE9D); border-radius: 15px; color: #333; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; box-shadow: 0px 0px 12px rgba(0,0,0,0.1);">

### Congratulations !!!!

