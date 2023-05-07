class configmovie:
    meta_diccol = ['belongs_to_collection','genres','production_countries','spoken_languages']
    metadf_int = ['budget', 'id','revenue','adult']
    metadf_float = ['popularity',  'vote_average','runtime', 'vote_count']
    metadf_str = ['belongs_to_collection','original_language', 'original_title','status']
    metadf_date = ['release_date']

    drop_moviemeta = ['genres','production_countries','spoken_languages','production_companies','homepage','imdb_id','overview','poster_path','tagline','title','video']
    drop_cast =['cast_id','credit_id','id','order','profile_path']
    drop_crew =['credit_id','id','profile_path']