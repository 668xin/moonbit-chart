# Chart Demo

## Monthly Sales

@chart: bar
title: Monthly Sales
width: 600
height: 400
categories: Jan, Feb, Mar, Apr, May, Jun
dataset: Product A, #4E79A7, 120, 200, 150, 80, 230, 180
dataset: Product B, #F28E2B, 90, 140, 200, 160, 120, 210
@end

## Revenue Trends

@chart: line
title: Revenue Trends
width: 600
height: 400
categories: Q1, Q2, Q3, Q4
dataset: Revenue, #4E79A7, 300, 450, 380, 520
dataset: Cost, #F28E2B, 200, 280, 250, 310
@end

## Market Share

@chart: pie
title: Market Share
width: 500
height: 400
dataset: Product A, #4E79A7, 35
dataset: Product B, #F28E2B, 25
dataset: Product C, #E15759, 20
dataset: Product D, #76B7B2, 15
dataset: Others, #B07AA1, 5
@end

## Performance Review

@chart: radar
title: Performance Review
width: 500
height: 500
categories: Speed, Quality, Cost, Service, Innovation
dataset: Team A, #4E79A7, 90, 80, 70, 85, 75
dataset: Team B, #F28E2B, 75, 85, 90, 70, 80
@end

## Stacked Bar Chart

@chart: bar
title: Stacked Expenses
width: 600
height: 400
theme: light
stacked: true
categories: Rent, Food, Transport, Entertainment
dataset: Alice, #4E79A7, 800, 400, 150, 200
dataset: Bob, #F28E2B, 800, 500, 200, 100
dataset: Carol, #E15759, 800, 300, 100, 300
@end
