import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading/indicator/line_scale_pulse_out_indicator.dart';
import 'package:loading/loading.dart';
import 'package:online_radio/widgets/loading_indicator_with_message.dart';
import 'package:online_radio/widgets/media_player_sheet.dart';
import 'package:online_radio/widgets/station_list_item.dart';
import 'package:online_radio/widgets/title_header.dart';

import 'blocs/player_bloc/player_bloc.dart';
import 'blocs/stations_bloc/stations_bloc.dart';
import 'widgets/idle_dots.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Online Radio'),
      ),
      body: Padding(
          padding: const EdgeInsets.only(bottom: 100),
          child: BlocBuilder<StationsBloc, StationsState>(
            builder: (context, state) {
              if (state is LoadingStations) {
                context.bloc<StationsBloc>().add(FetchStations());
                return LoadingIndicatorWithMessage(
                  label: 'Fetching stations',
                );
              } else if (state is StationsFetchedState) {
                final stations = (context.bloc<StationsBloc>().state as StationsFetchedState).stations;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TitleHeader(
                      title: 'Top Stations',
                      status: BlocBuilder<PlayerBloc, PlayerState>(builder: (context, state) {
                        if (state is PausedState || state is StoppedState) {
                          return IdleDots(
                            color: Theme.of(context).accentColor,
                          );
                        } else {
                          return Loading(
                            indicator: LineScalePulseOutIndicator(),
                            size: 30,
                            color: Theme.of(context).accentColor,
                          );
                        }
                      }),
                    ),
                    Expanded(
                      child: ListView.builder(
                          itemCount: stations.length,
                          itemBuilder: (context, index) {
                            return StationListItem(
                              name: stations[index].name,
                              stationImage: Image.network(stations[index].imageUrl),
                              onTap: () {
                                context.bloc<PlayerBloc>().add(PlayEvent(stations[index]));
                              },
                            );
                          }),
                    ),
                  ],
                );
              } else {
                return Center(
                  child: Text('Error Fetching Statons'),
                );
              }
            },
          )),
      bottomSheet: BlocBuilder<PlayerBloc, PlayerState>(
        builder: (context, state) {
          if (state is StoppedState) {
            return Container(
              color: Theme.of(context).primaryColor,
              height: 100,
            );
          } else if (state is PlayingState) {
            final currentStation = state.currentStation;
            return MediaPlayerSheet(
              title: currentStation.name,
              imageUrl: currentStation.imageUrl,
              mediaButtonIcon: Icon(
                Icons.pause,
                size: 32,
              ),
              onMediaButtonPress: () {
                context.bloc<PlayerBloc>().add(PauseEvent());
              },
            );
          } else {
            final currentStation = (state as PausedState).currentStation;
            return MediaPlayerSheet(
              title: currentStation.name,
              imageUrl: currentStation.imageUrl,
              mediaButtonIcon: Icon(
                Icons.play_arrow,
                size: 32,
              ),
              onMediaButtonPress: () {
                context.bloc<PlayerBloc>().add(PlayEvent(currentStation));
              },
            );
          }
        },
      ),
    );
  }
}
