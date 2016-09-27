import psycopg2

def get_cd_od_matrix(conn):
    cur = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)

    cur.execute("""select a.zone_id as o, b.zone_id as d, ST_Distance(ST_Transform(ac, 26917), ST_Transform(bc, 26917))/1000 as dist from (
                select CAST(cduid AS integer) as zone_id, ST_Centroid(geom) as ac from census_divisions where pruid = '35'
                union
                select zone_id, ST_Centroid(geom) from external_zones_v2
            ) as a,
             (
                select CAST(cduid AS integer) as zone_id, ST_Centroid(geom) as bc from census_divisions where pruid = '35'
                union
                select zone_id, ST_Centroid(geom) from external_zones_v2
            ) as b""")
    od_matrix = {(a['o'],a['d']): a['dist'] for a in cur.fetchall()}
    return od_matrix