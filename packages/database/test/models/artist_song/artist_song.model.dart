import 'package:illuminate_database/query_builder.dart';

part 'artist_song.model.g.dart';

@DoxModel()
class ArtistSong extends ArtistSongGenerator {
  @Column(name: 'blog_id')
  int? songId;

  @Column(name: 'artist_id')
  int? artistId;
}
