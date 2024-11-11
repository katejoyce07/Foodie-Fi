CREATE TABLE "CS.Foodie.Fi.Plans" (
  "PLAN_ID" bigint,
  "PLAN_NAME" text,
  "PRICE" double precision NULL
);

INSERT INTO "CS.Foodie.Fi.Plans" ("PLAN_ID","PLAN_NAME","PRICE")
VALUES
(0,'trial',0),
(1,'basic monthly',9.9),
(2,'pro monthly',19.9),
(3,'pro annual',199),
(4,'churn',NULL);

