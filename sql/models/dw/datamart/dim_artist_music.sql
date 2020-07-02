{{ config(materialized='table') }}

with tracks_combined as
(
-- unearthed tracks
select
    'unearthed'                           as artist_music_source
  , spine.artist_id
  , unearthed_track.unearthed_track_url   as artist_music_url
from
  {{ ref('stg_artist_spine') }} spine
  join
  {{ ref('unearthed_track') }} unearthed_track
    using ( unearthed_artist_id )
union distinct
-- spotify tracks
select
    'spotify'               as artist_music_source
  , spine.artist_id
  , spotify.track_url       as artist_music_url
from
  {{ ref('stg_artist_spine') }} spine
  join
  {{ ref('spotify_artist_tracks') }} spotify
    using ( spotify_artist_id )
)
select
    to_hex ( {{ dbt_utils.surrogate_key('artist_music_source','artist_music_url' ) }} ) as artist_music_id
  , artist_id
  , artist_music_source
  , artist_music_url
from
  tracks_combined
