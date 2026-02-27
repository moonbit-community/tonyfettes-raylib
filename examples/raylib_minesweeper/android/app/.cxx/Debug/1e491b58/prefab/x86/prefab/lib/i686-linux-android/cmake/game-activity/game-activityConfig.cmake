if(NOT TARGET game-activity::game-activity)
add_library(game-activity::game-activity STATIC IMPORTED)
set_target_properties(game-activity::game-activity PROPERTIES
    IMPORTED_LOCATION "/Users/haoxiang/.gradle/caches/9.2.1/transforms/66e70da66cb7820b0270646b5347069c/transformed/games-activity-4.0.0/prefab/modules/game-activity/libs/android.x86/libgame-activity.a"
    INTERFACE_INCLUDE_DIRECTORIES "/Users/haoxiang/.gradle/caches/9.2.1/transforms/66e70da66cb7820b0270646b5347069c/transformed/games-activity-4.0.0/prefab/modules/game-activity/include"
    INTERFACE_LINK_LIBRARIES ""
)
endif()

if(NOT TARGET game-activity::game-activity_static)
add_library(game-activity::game-activity_static STATIC IMPORTED)
set_target_properties(game-activity::game-activity_static PROPERTIES
    IMPORTED_LOCATION "/Users/haoxiang/.gradle/caches/9.2.1/transforms/66e70da66cb7820b0270646b5347069c/transformed/games-activity-4.0.0/prefab/modules/game-activity_static/libs/android.x86/libgame-activity_static.a"
    INTERFACE_INCLUDE_DIRECTORIES "/Users/haoxiang/.gradle/caches/9.2.1/transforms/66e70da66cb7820b0270646b5347069c/transformed/games-activity-4.0.0/prefab/modules/game-activity_static/include"
    INTERFACE_LINK_LIBRARIES ""
)
endif()

