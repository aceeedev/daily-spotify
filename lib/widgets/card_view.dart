import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:daily_spotify/providers/setup_provider.dart';
import 'package:daily_spotify/backend/spotify_api/spotify_api.dart';

/// A [GridView] of custom [Card]s.
///
/// The parameter [type] can either be [Artist] or [Track].
///
/// The parameter [itemList] is a [List] of [Map<String, dynamic>]. The key value
/// pairs are as follows:
/// item: [Artist] or [Track] required, the main item to be displayed
/// selected: [bool] optional, if true, the card is selected, if false, card is
///   unselected
class CardView extends StatefulWidget {
  const CardView({super.key, required this.itemList, required this.type});

  final List<Map<String, dynamic>> itemList;
  final Type type;

  @override
  State<CardView> createState() => _CardViewState();
}

class _CardViewState extends State<CardView> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemCount: widget.itemList.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> item = widget.itemList[index];

        return CustomCard(
            item: item['item'],
            selected: item['selected'] ?? false,
            type: widget.type);
      },
    );
  }
}

class CustomCard extends StatefulWidget {
  CustomCard(
      {super.key,
      required this.item,
      required this.selected,
      required this.type});

  final dynamic item;
  bool selected;
  final Type type;

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard>
    with AutomaticKeepAliveClientMixin {
  // ensures the state is maintained when navigating off screen
  @override
  bool get wantKeepAlive => true;

  late String? artists;
  @override
  void initState() {
    super.initState();

    artists = getArtists();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          if (widget.selected) {
            switch (widget.type) {
              case Artist:
                {
                  context
                      .read<SetupForm>()
                      .removeFromSelectedArtistList(widget.item);
                }
                break;
              case Track:
                {
                  context
                      .read<SetupForm>()
                      .removeFromSelectedTrackList(widget.item);
                }
                break;
              default:
                {
                  throw Exception(
                      'Invalid Type, must be either Artist or Track but was ${widget.type}');
                }
            }

            setState(() {
              widget.selected = false;
            });
          } else {
            final dynamic addedItem;
            switch (widget.type) {
              case Artist:
                {
                  addedItem = context
                      .read<SetupForm>()
                      .addToSelectedArtistList(widget.item);
                }
                break;
              case Track:
                {
                  addedItem = context
                      .read<SetupForm>()
                      .addToSelectedTrackList(widget.item);
                }
                break;
              default:
                {
                  throw Exception(
                      'Invalid Type, must be either Artist or Track but was ${widget.type}');
                }
            }

            if (addedItem != null) {
              setState(() {
                widget.selected = true;
              });
            }
          }
        },
        child: Card(
            color: widget.selected ? Colors.grey[200] : null,
            child: Column(children: [
              AspectRatio(
                aspectRatio: 8 / 7,
                child: Image.network(
                    (widget.item.images[1] as SpotifyImage).url,
                    width: (widget.item.images[1] as SpotifyImage)
                        .width
                        .toDouble(),
                    height: (widget.item.images[1] as SpotifyImage)
                        .height
                        .toDouble()),
              ),
              Text(widget.item.name),
              widget.type == Track
                  ? Text(artists ?? '')
                  : const SizedBox.shrink()
            ])),
      );

  String? getArtists() {
    if (widget.type != Track) {
      return null;
    }

    List<String> artists = [];
    for (var artist in (widget.item.artists as List<Artist>)) {
      artists.add(artist.name);
    }

    return artists.join(', ');
  }
}
