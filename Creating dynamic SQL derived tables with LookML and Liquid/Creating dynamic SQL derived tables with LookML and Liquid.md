
<div align="center" style="padding: 25px; background: #f2f2f2; border-radius: 15px; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; box-shadow: 0px 0px 10px rgba(0,0,0,0.1);">

<h1 style="color: #2F80ED;">🚀 Creating dynamic SQL derived tables with LookML and Liquid | GSP932 </h1>


<br/>

<a href="https://www.cloudskillsboost.google/focuses/21215?parent=catalog" target="_blank" style="margin: 10px;">
  <img src="https://img.shields.io/badge/Access_Lab-4285F4?style=for-the-badge&logo=googlecloud&logoColor=white" alt="Access Lab">
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

<div align="center" style="margin-top: 20px;">



</div>

<br/>

<h3>🚀 Open -> training_ecommerce  File</h3>


```bash
connection: "bigquery_public_data_looker"

# include all the views
include: "/views/*.view"
include: "/z_tests/*.lkml"
include: "/**/*.dashboard"

datagroup: training_ecommerce_default_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "1 hour"
}

persist_with: training_ecommerce_default_datagroup

label: "E-Commerce Training"

explore: order_items {

  join: user_facts {
    type: left_outer
    sql_on: ${order_items.user_id} = ${user_facts.user_id};;
    relationship: many_to_one
  }

  join: users {
    type: left_outer
    sql_on: ${order_items.user_id} = ${users.id} ;;
    relationship: many_to_one
  }

  join: inventory_items {
    type: left_outer
    sql_on: ${order_items.inventory_item_id} = ${inventory_items.id} ;;
    relationship: many_to_one
  }

  join: products {
    type: left_outer
    sql_on: ${inventory_items.product_id} = ${products.id} ;;
    relationship: many_to_one
  }

  join: distribution_centers {
    type: left_outer
    sql_on: ${products.distribution_center_id} = ${distribution_centers.id} ;;
    relationship: many_to_one
  }
}

explore: events {
  join: event_session_facts {
    type: left_outer
    sql_on: ${events.session_id} = ${event_session_facts.session_id} ;;
    relationship: many_to_one
  }
  join: event_session_funnel {
    type: left_outer
    sql_on: ${events.session_id} = ${event_session_funnel.session_id} ;;
    relationship: many_to_one
  }
  join: users {
    type: left_outer
    sql_on: ${events.user_id} = ${users.id} ;;
    relationship: many_to_one
  }
}

```

<h3>🚀 Create -> `user_facts`  File</h3>


```bash
view: user_facts {
  derived_table: {
    sql: SELECT
           order_items.user_id AS user_id
          ,COUNT(distinct order_items.order_id) AS lifetime_order_count
          ,SUM(order_items.sale_price) AS lifetime_revenue
          ,MIN(order_items.created_at) AS first_order_date
          ,MAX(order_items.created_at) AS latest_order_date
          FROM cloud-training-demos.looker_ecomm.order_items
          WHERE {% condition select_date %} order_items.created_at {% endcondition %}
          GROUP BY user_id;;
  }
  
  filter: select_date {
    type: date
    suggest_explore: order_items
    suggest_dimension: order_items.created_date
  }

  measure: count {
    hidden: yes
    type: count
    drill_fields: [detail*]
  }

  dimension: user_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.user_id ;;
  }

  dimension: lifetime_order_count {
    type: number
    sql: ${TABLE}.lifetime_order_count ;;
  }

  dimension: lifetime_revenue {
    type: number
    sql: ${TABLE}.lifetime_revenue ;;
  }

  measure: average_lifetime_revenue {
    type: average
    sql: ${TABLE}.lifetime_revenue ;;
  }


  measure: average_lifetime_order_count {
    type: average
    sql: ${TABLE}.lifetime_order_count ;;
  }

  dimension_group: first_order_date {
    type: time
    sql: ${TABLE}.first_order_date ;;
  }

  dimension_group: latest_order_date {
    type: time
    sql: ${TABLE}.latest_order_date ;;
  }

  set: detail {
    fields: [user_id, lifetime_order_count, lifetime_revenue, first_order_date_time, latest_order_date_time]
  }
}

```


<p style="font-size: 15px; color: #555;"><i>👉 This runs the script to set up your environment. It provisions resources and configures as needed.</i></p>

<hr style="border: none; height: 1px; background: #ddd; margin: 30px 0;">



<div align="left" style="padding: 25px; background: linear-gradient(135deg, #00C9FF, #92FE9D); border-radius: 15px; color: #333; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; box-shadow: 0px 0px 12px rgba(0,0,0,0.1);">

<h2 style="margin-bottom: 10px;">🎉 Lab Completed!</h2>



</div>

