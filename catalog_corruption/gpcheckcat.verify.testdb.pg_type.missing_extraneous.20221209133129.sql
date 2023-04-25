
          SELECT *
          FROM (
               SELECT relname, oid FROM pg_class WHERE reltype IN (24223,24231,24237,24241,24243,24247,24249,24432,24462,24468,24474,24193,24195,24199,24205,24450,24456,24192,24198,24234,24240,24246,24447,24457,24463,24465,24469,24471,24475,24481,24483,24201,24207,24211,24213,24217,24219,24225,24229,24235,24438,24444,24480,24486,24445,24477,24487,24489,24204,24210,24216,24222,24228,24433,24435,24439,24441,24451,24453,24459)
               UNION ALL
               SELECT relname, oid FROM gp_dist_random('pg_class') WHERE reltype IN (24223,24231,24237,24241,24243,24247,24249,24432,24462,24468,24474,24193,24195,24199,24205,24450,24456,24192,24198,24234,24240,24246,24447,24457,24463,24465,24469,24471,24475,24481,24483,24201,24207,24211,24213,24217,24219,24225,24229,24235,24438,24444,24480,24486,24445,24477,24487,24489,24204,24210,24216,24222,24228,24433,24435,24439,24441,24451,24453,24459)
          ) alltyprelids
          GROUP BY relname, oid ORDER BY count(*) desc
    
