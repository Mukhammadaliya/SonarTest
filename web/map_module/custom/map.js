// It should be outside to use its values inside html
const mapCallbacks = {};
const mapSelectionHandlers = [];

function init(langs, options) {
  // Main map image url
  const OSMTileLayer = 'https://map.greenwhite.uz/osm/{z}/{x}/{y}.png';
  const OSMSearchUrl = 'https://nominatim.openstreetmap.org/search?format=json&q={s}';
  // 4 profiles for routing
  const OSRMUrls = {
    car: {
      serviceUrl: 'https://map-route-car.greenwhite.uz/route/v1',
      profile: 'driving'
    },
    walking: {
      serviceUrl: 'https://map-route-foot.greenwhite.uz/route/v1',
      profile: 'walking'
    },
    biking: {
      serviceUrl: 'https://map-route-bike.greenwhite.uz/route/v1',
      profile: 'cycling'
    },
    truck: {
      serviceUrl: 'https://map-route-truck.greenwhite.uz/route/v1',
      profile: 'driving'
    }
  };

  let markerGroups = [],
      groupedLayers,
      scaleControl,
      searchControl,
      markers = [],
      routeControls = [],
      routeMarkers = {},
      placemark = {},
      polyline = {},
      polyline_with_arrows = {},
      profileMode = options.profile || 'car',
      profileMainIcon = null,
      profiles = ['truck', 'car', 'biking', 'walking'],
      circle = {},
      polygons = {};

  if (options.mapCallbacks) _.extend(mapCallbacks, options.mapCallbacks);

  if (options.center?.length < 2) {
    alert('Error, lat-lng is empty!');
  }

  const deferredApi = $.Deferred();

  const map = new L.Map('map', {
    center: new L.LatLng(options.center[0], options.center[1]),
    zoom: options.zoom,
    fullscreenControl: options.fullscreen,
    fullscreenControlOptions: {
      position: 'topleft'
    }
  });

  const controls = {
    'OSM': L.tileLayer(OSMTileLayer).addTo(map),
    'Yandex': new L.Yandex('map'),
    'Yandex Satellite': new L.Yandex('satellite'),
    'Google Hybrid': L.tileLayer('https://{s}.google.com/vt/lyrs=s,h&x={x}&y={y}&z={z}', {
      maxZoom: 20,
      subdomains: ['mt0', 'mt1', 'mt2', 'mt3']
    }),
    'Google Satellite': L.tileLayer('https://{s}.google.com/vt/lyrs=s&x={x}&y={y}&z={z}', {
      maxZoom: 20,
      subdomains: ['mt0', 'mt1', 'mt2', 'mt3']
    })
  };

  const controller = new L.Control.Layers(controls, {});

  map.addControl(controller);

  if (options.showProfiles) {
    L.Control.Profile = L.Control.extend({
      options: {
        position: 'bottomright'
      },
      onAdd: function (m) {
        const container = L.DomUtil.create('div', 'position-relative');
        const toggleBtn = L.DomUtil.create('button', 'btn btn-default py-1 px-0 text-center', container);
        toggleBtn.style.width = '35px';
        profileMainIcon = L.DomUtil.create('i', 'main-icon fa fa-' + profileMode, toggleBtn);
        profileMainIcon.style.fontSize = 'small';

        L.DomEvent.on(container, 'mouseover', function (ev) {
          const menu = toggleBtn.nextSibling;
          menu.style.display = 'block';
        });
        L.DomEvent.on(container, 'mouseleave', function (ev) {
          const menu = toggleBtn.nextSibling;
          menu.style.display = 'none';
        });

        const menu = L.DomUtil.create('div', 'position-absolute bg-white rounded p-1', container);
        menu.style.display = 'none';
        menu.style.right = 0;
        menu.style.bottom = 0;

        _.each(options.allowedProfiles || profiles, function (x) {
          const a = L.DomUtil.create('a', 'dropdown-item text-center p-2', menu);
          a.style.cursor = 'pointer';
          L.DomUtil.create('i', 'fa fa-' + x, a);
          L.DomEvent.on(a, 'click', ()=>changeProfile(x));
        });

        return container;
      },
    });

    const profileControl = new L.Control.Profile();
    map.addControl(profileControl);
  }

  // ------------- BEGIN SELECT MODE --------------------------------

  const SELECT_MODE = options.mode === "select";

  if (SELECT_MODE) {
    let selectedMarkers = [];
    let toolbar = options?.toolbar || {};
    const DEFAULT_ICON_FOR_MARKER = 'default';
    const SELECTION_ICON_FOR_MARKER = 'group_marks/a-05';

    map.pm.setLang(langs.langCode);
    map.pm.addControls({
      position: toolbar.position ?? 'topleft', // 'topleft', 'topright', 'bottomleft', 'bottomright'
      drawMarker: toolbar.drawMarker ?? false,
      drawCircleMarker: toolbar.drawCircleMarker ?? false,
      drawPolyline: toolbar.drawPolyline ?? false,
      drawRectangle: toolbar.drawRectangle ?? true,
      drawPolygon: toolbar.drawPolygon ?? true,
      drawCircle: toolbar.drawCircle ?? false,
      drawText: toolbar.drawText ?? false,
      editMode: toolbar.editMode ?? true,
      dragMode: toolbar.dragMode ?? true,
      cutPolygon: toolbar.cutPolygon ?? false,
      removalMode: toolbar.removalMode ?? true,
      rotateMode: toolbar.rotateMode ?? true,
      oneBlock: toolbar.oneBlock ?? false,
      drawControls: toolbar.drawControls ?? true,
      editControls: toolbar.editControls ?? true,
      customControls: toolbar.customControls ?? true,
      optionsControls: toolbar.optionsControls ?? true,
      pinningOption: toolbar.pinningOption ?? true,
      snappingOption: toolbar.snappingOption ?? true,
      splitMode: toolbar.splitMode ?? true,
      scaleMode: toolbar.scaleMode ?? true,
      autoTracingOption: toolbar.autoTracingOption ?? false,
    });

    if (options.selectionHandler) {
      mapSelectionHandlers.push(options.selectionHandler);
    }

    map.on("pm:create", function (e) {
      const layer = e.layer;
      layer.on("pm:edit", (e) => {
        calculateObjectsForSelection(e);
      });
      layer.on("pm:remove", (e) => {
        calculateObjectsForSelection(e);
      });

      calculateObjectsForSelection(e);
    });

    function toggleSelection(marker, sendSignal) {
      let i = selectedMarkers.indexOf(marker);
      if (i >= 0) {
        marker.setIcon(getIcon(DEFAULT_ICON_FOR_MARKER));
        selectedMarkers.splice(i, 1);
      } else {
        marker.setIcon(getIcon(SELECTION_ICON_FOR_MARKER));
        selectedMarkers.push(marker);
      }
      if (sendSignal) sendSignalToHandlers();
    }

    function calculateObjectsForSelection(e) {
      const layers = map.pm.getGeomanDrawLayers();
      const group = L.featureGroup();
      layers.forEach((layer) => {
        group.addLayer(layer);
      });

      let polyCoords = group
        .toGeoJSON()
        .features.map((p) => p.geometry.coordinates[0]);

      selectedMarkers = markers
        .filter((m) => {
          let isIn = checkPointInPolygons([m.getLatLng().lat, m.getLatLng().lng], polyCoords);
          if (isIn) {
            m.setIcon(getIcon(SELECTION_ICON_FOR_MARKER));
          } else {
            m.setIcon(getIcon(DEFAULT_ICON_FOR_MARKER));
          }
          return isIn;
        });
      sendSignalToHandlers(e);
    }

    function sendSignalToHandlers(e) {
      for (const handler of mapSelectionHandlers) {
        try {
          handler(selectedMarkers, e);
        } catch (e) {
          console.error(e);
        }
      }
    }

    function checkPointInPolygons(point, polyCoords) {
      for (const poly of polyCoords) {
        if (rayCasting(point, poly)) return true;
      }
      return false;
    }

    // method Ray Casting.
    function rayCasting(point, polygon) {
      let n = polygon.length,
        is_in = false,
        x = point[1],
        y = point[0],
        x1, x2, y1, y2;

      for (let i = 0; i < n - 1; ++i) {
        x1 = polygon[i][0];
        x2 = polygon[i + 1][0];
        y1 = polygon[i][1];
        y2 = polygon[i + 1][1];

        if (y < y1 !== y < y2 && x < (x2 - x1) * (y - y1) / (y2 - y1) + x1) {
          is_in = !is_in;
        }
      }
      return is_in;
    }

    function removeLayer(layer) {
      map.removeLayer(layer);
    }

    function polygonLayer(name) {
      return polygons[name];
    }

    function disableDraw() {
      map.pm.disableDraw();
    }

    function disableEditMode() {
      map.pm.disableGlobalEditMode();
    }

    function addToolbar(options) {
      map.pm.addControls(options);
    }

    function removeToolbar() {
      map.pm.removeControls();
      disableDraw();
      disableEditMode();
    }

    function toggleToolbar() {
      map.pm.toggleControls();
    }
  }

  // ------------- END SELECT MODE --------------------------------

  const myURL = $('script[src$="map.js"]').attr('src').replace('map.js', '');

  function resolveApi() {
    if (deferredApi.state() === "resolved") return;
    deferredApi.resolve({
      flyTo: flyTo, // smoothly sets view to given lat,lng,zoom
      setCenter: setCenter,
      getCenter: getCenter,
      setZoom: setZoom,
      getZoom: getZoom,
      setView: setView, // instantly sets view to given lat,lng,zoom
      searchText: searchText,
      enableSearch: enableSearch,
      disableSearch: disableSearch,
      selectLatLng: selectLatLng,
      addMarkers: addMarkers,
      removeMarkers: removeMarkers,
      showMarkerPopup: showMarkerPopup, // sets view to selected marker
      addPlacemark: addPlacemark,
      removePlacemark: removePlacemark,
      removePlacemarks: removePlacemarks,
      showPlacemarkPopup: showPlacemarkPopup,
      addPolyline: addPolyline,
      removePolyline: removePolyline,
      addPolylineWithArrows: addPolylineWithArrows,
      removePolylineWithArrows: removePolylineWithArrows,
      addCircle: addCircle,
      removeCircle: removeCircle,
      removeCircles: removeCircles,
      showCirclePopup: showCirclePopup,
      drawRoute: drawRoute,
      removeRoute: removeRoute,
      routeMarkerLatLng: routeMarkerLatLng,
      addPolygon: addPolygon,
      removePolygon: removePolygon,
      // for select mode
      addSelectionHandler: addSelectionHandler,
      toggleSelection: toggleSelection,
      removeLayer: removeLayer,
      polygonLayer: polygonLayer,
      disableDraw: disableDraw,
      disableEditMode: disableEditMode,
      addToolbar: addToolbar,
      removeToolbar: removeToolbar,
      toggleToolbar: toggleToolbar,
      fitBounds: fitBounds,
    });
  }

  function getDivIcon(iconColor, options) {
    const icon = L.extend({
      html: `<div style="left: -1rem; top: -0.5rem; position: relative">
               <svg width="27" height="38" viewBox="0 0 27 50" fill="none" xmlns="http://www.w3.org/2000/svg">
                 <g filter="url(#filter0_d)">
                   <path d="M18 43.2443C17.9338 43.1682 17.8593 43.0824 17.7772 42.9871C17.3972 42.546 16.8535 41.9033 16.2007 41.099C14.8947 39.4897 13.1541 37.2362 11.4145 34.6579C9.67392 32.0781 7.94053 29.1823 6.6438 26.2878C5.34414 23.3867 4.5 20.5238 4.5 18C4.5 14.4196 5.92232 10.9858 8.45406 8.45406C10.9858 5.92232 14.4196 4.5 18 4.5C21.5804 4.5 25.0142 5.92232 27.5459 8.45406C30.0777 10.9858 31.5 14.4196 31.5 18C31.5 20.5238 30.6559 23.3867 29.3562 26.2878C28.0595 29.1823 26.3261 32.0781 24.5855 34.6579C22.8459 37.2362 21.1053 39.4897 19.7993 41.099C19.1465 41.9033 18.6028 42.546 18.2228 42.9871C18.1407 43.0824 18.0662 43.1682 18 43.2443Z" fill="${iconColor}" stroke="white" />
                   <circle cx="18" cy="18" r="4" fill="white" />
                 </g>
                 <defs>
                   <filter id="filter0_d" x="-2" y="-2" width="40" height="56" filterUnits="userSpaceOnUse" color-interpolation-filters="sRGB">
                     <feFlood flood-opacity="0" result="BackgroundImageFix" />
                     <feColorMatrix in="SourceAlpha" type="matrix" values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0" />
                     <feOffset dy="2" />
                     <feGaussianBlur stdDeviation="2" />
                     <feColorMatrix type="matrix" values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.75 0" />
                     <feBlend mode="normal" in2="BackgroundImageFix" result="effect1_dropShadow" />
                     <feBlend mode="normal" in="SourceGraphic" in2="effect1_dropShadow" result="shape" />
                   </filter>
                 </defs>
               </svg>
             </div>`,
      iconAnchor: [0, 24],
      labelAnchor: [-6, 0],
      popupAnchor: [0, -30],
    }, options);

    return L.divIcon(icon);
  }

  function getCustomIcon(html, options) {
    let icon = L.extend({
      html: html,
      iconSize: [30, 40],
      popupAnchor: [0, -30]
    }, options);

    return L.divIcon(icon);
  }

  function getIcon(type, options) {
    let icon = L.extend({
      iconUrl: myURL + 'icons/map/' + (type || 'default') + '.svg',
      iconSize: [30, 40],
      iconAnchor: [15, 34],
      popupAnchor: [0, -30]
    }, options);
    icon.iconRetinaUrl = icon.iconUrl;
    return L.icon(icon);
  }

  function flyTo(latlng, zoom) {
    if (!latlng) alert('Error, lat-lng is empty!');
    map.flyTo(new L.LatLng(...latlng), zoom);
  }

  function setCenter(latlng) {
    if (!latlng) alert('Error, lat-lng is empty!');
    map.setView(new L.LatLng(...latlng));
  }

  function getCenter() {
    return map.getCenter();
  }

  function setZoom(zoom) {
    if (!zoom) alert('Error, zoom is empty!');
    map.setZoom(zoom);
  }

  function getZoom() {
    return map.getZoom();
  }

  function setView(lat, lng, zoom) {
    if (!lat || !lng) alert('Error, lat or lng is empty!');
    return map.setView([lat, lng], zoom || map.getZoom());
  }

  function selectLatLng(lat, lng, popup, moveFunc, iconColor) {
    let marker = null;

    if (lat && lng) {
      createMarker(lat, lng, popup, moveFunc, iconColor);
    }

    function createMarker(xLat, xLng, popup, onMoveFunc, iconColor) {
      map.doubleClickZoom.disable();

      marker = new L.marker([xLat, xLng], {
        icon: iconColor ? getDivIcon(iconColor) : getIcon(),
        draggable: true
      });

      if (onMoveFunc) {
        marker.on('move', onMoveFunc);
      }

      if (popup) {
        marker.bindPopup(popup);
      }

      map.addLayer(marker);

      return marker;
    }

    function onDblClick(e) {
      if (marker) {
        marker.setLatLng(e.latlng);
      } else {
        createMarker(e.latlng.lat, e.latlng.lng, popup, moveFunc, iconColor);
      }
    }

    map.on('dblclick', onDblClick);

    function remove() {
      map.off('dblclick', onDblClick);
      if (marker) {
        map.removeLayer(marker);
      }
    }

    return {
      lat: function () {
        if (marker) {
          return marker.getLatLng().lat;
        }
      },
      lng: function () {
        if (marker) {
          return marker.getLatLng().lng;
        }
      },
      setLatLng: function (lat, lng, iconColor) {
        if (marker) {
          marker.setLatLng(new L.LatLng(lat, lng));
          if (iconColor) {
            marker.setIcon(getDivIcon(iconColor));
          }
        }
      },
      remove: remove
    };
  }

  function fitBounds(points) {
    let bounds = _.map(points, function (x) { return [x.lat, x.lng]; });

    if (bounds.length) {
      map.fitBounds(L.latLngBounds(bounds));
    }
  }

  function addMarkers(places, disableCluster, autoFit) {
    let markerClusterGroup = new L.markerClusterGroup({
      spiderLegPolylineOptions: {opacity: .2},
      iconCreateFunction: function (cluster) {
        return L.divIcon({html: '<b>' + cluster.getChildCount() + '</b>', className: 'my-cluster'})
      }
    });
    let markerLayerGroup = new L.layerGroup();

    for (let i = 0; i < places.length; i++) {
      const popup = L.DomUtil.create('div', 'infoWindow');
      popup.innerHTML = places[i].title;

      if (places[i].popupEvent) {
        $(places[i].popupId, popup).on(places[i].popupEvent, places[i].popupEventCallback);
      }

      markers[i] = L.marker([places[i].lat, places[i].lng], {
        object: places[i].object, // for select mode
        draggable: places[i].draggable,
        icon: places[i].iconColor ? getDivIcon(places[i].iconColor) : places[i].iconHtml ? getCustomIcon(places[i].iconHtml, places[i].iconOptions) : getIcon(places[i].icon, places[i].iconOptions)
      }).bindPopup(popup);

      if (places[i].showPopupEvent) {
        markers[i].on(places[i].showPopupEvent, function (e) {
          this.openPopup();
        });
      }

      if (places[i].markerEvent) {
        markers[i].on(places[i].markerEvent, places[i].markerEventCallback);
      }
      if (SELECT_MODE) {
        if(places[i].object) places[i].object.marker = markers[i];
        markers[i].on('dblclick', (e) => toggleSelection(e.target, true));
        markers[i].on('click', function (e) {
          if (map.pm.globalRemovalEnabled()) {
            throw new Error('marker cannot be removed in select mode');
          }
        });
        markers[i]._pmTempLayer = true;
        markers[i]._dragDisabled = true;
      }

      markerClusterGroup.addLayer(markers[i]);
      markerLayerGroup.addLayer(markers[i]);
    }

    let groupedOverlays = {};
    groupedOverlays[langs().map_grouping] = {};
    groupedOverlays[langs().map_grouping][langs().yes] = markerClusterGroup;
    groupedOverlays[langs().map_grouping][langs().no] = markerLayerGroup;

    if (disableCluster) {
      markerLayerGroup.addTo(map);
    } else {
      markerClusterGroup.addTo(map);
    }

    const options = {
      exclusiveGroups: [langs().map_grouping],
      groupCheckboxes: true
    };

    controller.remove(map);

    if (groupedLayers) {
      groupedLayers.remove(map);
    }

    groupedLayers = new L.control.groupedLayers(controls, groupedOverlays, options);
    groupedLayers.addTo(map);

    markerGroups.push(markerClusterGroup);
    markerGroups.push(markerLayerGroup);

    if (autoFit) {
      fitBounds(places);
    }
  }

  function searchText(text) {
    if (searchControl) {
      searchControl.searchText(text);
    }
  }

  function enableSearch(onSelectFunc) {
    disableSearch();
    searchControl = L.control.search({
      url: OSMSearchUrl,
      propertyName: 'display_name',
      jsonpParam: 'json_callback',
      propertyLoc: ['lat', 'lon'],
      autoCollapse: true,
      autoType: false,
      firstTipSubmit: true,
      minLength: 2,
      moveToLocation: onSelectFunc ? function (latlng, title, map) {
        onSelectFunc(latlng, title);
      } : null
    }).addTo(map);
  }

  function disableSearch() {
    if (searchControl) {
      map.removeControl(searchControl);
      searchControl = null;
    }
  }

  function removeMarkers() {
    _.each(markerGroups, function (gr) {
      map.removeLayer(gr || {});
    });
    markerGroups = [];
    markers = [];
  }

  function showMarkerPopup(index, zoom) {
    map.setView(markers[index].getLatLng(), zoom);
    markers[index].openPopup();
  }

  function addPlacemark(key, latlng, icon, popup, iconColor) {
    placemark[key] = L.marker(latlng, {
      draggable: false,
      icon: iconColor ? getDivIcon(iconColor) : getIcon(icon),
    }).bindPopup(popup).addTo(map);
  }

  function removePlacemark(key) {
    if (!placemark[key]) return;
    map.removeLayer(placemark[key]);
    delete placemark[key];
  }

  function removePlacemarks() {
    const values = _.values(placemark);
    for (let i = 0; i < values.length; i++)
      map.removeLayer(values[i]);
    placemark = {};
  }

  function showPlacemarkPopup(key, zoom) {
    if (!placemark[key]) return;
    map.setView(placemark[key].getLatLng(), zoom);
    placemark[key].openPopup();
  }

  function addPolyline(key, latlngs, options, popup) {
    // options: color, weight, opacity, dashArray, lineJoin, ...
    removePolyline(key);
    polyline[key] = L.polyline(latlngs, options).addTo(map);

    if (popup) {
      let l_popup = new L.Popup(popup.options);
      l_popup.setContent(popup.content);

      if (popup.popupEvent) {
        $(key, l_popup).on(popup.popupEvent, popup.popupEventCallback);
      }

      polyline[key].bindPopup(l_popup);

      if (popup.showPopupEvent) {
        polyline[key].on(popup.showPopupEvent, function (e) {
          this.openPopup();
        });
      }
    }
  }

  function removePolyline(key) {
    if (!polyline[key]) return;
    map.removeLayer(polyline[key]);
    delete polyline[key];
  }

  function addPolylineWithArrows(key, latlngs, options) {
    // options: color, weight, opacity, dashArray, lineJoin, ...
    removePolylineWithArrows(key);
    polyline_with_arrows[key] = [];
    polyline_with_arrows[key + '_head'] = [];

    const pathOptions = {stroke: true};
    if (options.color) pathOptions['color'] = options.color;
    if (options.weight) pathOptions['weight'] = options.weight;
    if (options.opacity) pathOptions['opacity'] = options.opacity;

    for (let i = 0; i < latlngs.length - 1; i++) {
      const arrow = L.polyline([latlngs[i], latlngs[i + 1]], options).addTo(map);
      const arrow_head = L.polylineDecorator(arrow, {
        patterns: [
          {
            offset: '100%',
            repeat: 0,
            symbol: L.Symbol.arrowHead({
              pixelSize: 10,
              polygon: false,
              pathOptions: pathOptions
            })
          }
        ]
      }).addTo(map);
      polyline_with_arrows[key].push(arrow);
      polyline_with_arrows[key + '_head'].push(arrow_head);
    }
  }

  function removePolylineWithArrows(key) {
    if (!polyline_with_arrows[key]) return;
    for (let i = 0; i < polyline_with_arrows[key].length; i++) {
      map.removeLayer(polyline_with_arrows[key][i]);
      map.removeLayer(polyline_with_arrows[key + '_head'][i]);
    }
    delete polyline_with_arrows[key];
    delete polyline_with_arrows[key + '_head'];
  }

  function addCircle(key, latlng, options, popup) {
    circle[key] = new L.circle(latlng, options).addTo(map);
    circle[key].bindPopup(popup);
  }

  function removeCircle(key) {
    if (!circle[key]) return;
    map.removeLayer(circle[key]);
    delete circle[key];
  }

  function removeCircles() {
    const values = _.values(circle);
    for (let i = 0; i < values.length; i++)
      map.removeLayer(values[i]);
    circle = {};
  }

  function showCirclePopup(key, zoom) {
    map.setCenter(circle[key].getLatLng());
    map.setZoom(zoom);
    circle[key].openPopup();
  }

  // merges close points
  function fuseRoutePoints(routePoints, fuseClosePoints) {
    if (!fuseClosePoints) return routePoints;

    function isClose(point1, point2) {
      const R = 6371; // Radius of the earth in km
      const degrad = Math.PI / 180;
      const dLat = (point2.lat - point1.lat) * degrad;
      const dLng = (point2.lng - point1.lng) * degrad;
      const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) + Math.cos(point1.lat * degrad) * Math.cos(point2.lat * degrad) * Math.sin(dLng / 2) * Math.sin(dLng / 2);
      const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
      const d = R * c * 1000; // Distance in meter
      // Assume that Point with accuracy is a "circle" (with radius of this accuracy).
      // To define if two points are close we found the distance between the farthest points of each "circle"
      // and check if this distance is lower than "50" or original points are too near ("10" meters)
      return d < 10 || d + parseFloat(point1.radius || 0) + parseFloat(point2.radius || 0) <= 50;
    }

    // returns center of all merging points
    function avg(nearhood) {
      let latSum = 0, lngSum = 0;
      _.each(nearhood, x => {
        latSum += parseFloat(x.lat);
        lngSum += parseFloat(x.lng);
      });
      let idx = parseInt(nearhood.length / 2);
      let point = _.clone(nearhood[idx]);
      point.lat = latSum / nearhood.length;
      point.lng = lngSum / nearhood.length;
      return point;
    }

    return _.chain(routePoints)
            .reduce((nearhood, point) => {
              if (!nearhood.length || point.required) {
                nearhood.push([]);
                _.last(nearhood).push(point);
                return nearhood;
              }
              const is_close_to_any = _.any(_.last(nearhood), p => isClose(p, point));
              if (!is_close_to_any || _.last(_.last(nearhood)).required) {
                nearhood.push([]);
              }
              _.last(nearhood).push(point);
              return nearhood;
            }, [])
            .map(avg)
            .value();
  }

  /* options:
    - fuseClosePoints - set true to merge close points,
    - fitBounds - set the map view so that all waypoints fit
  */
  function drawRoute(routePoints, options) {
    if (routePoints.length < 1) return;

    let old_point;
    let newPoints = fuseRoutePoints(routePoints, options.fuseClosePoints);
    let routeChunks = _.chain(newPoints)
      .chunk(200)
      .map(chunk => {
        if (old_point) chunk.unshift(old_point);
        old_point = _.last(chunk);
        return chunk;
      })
      .value();

    if (options.fitBounds) {
      fitBounds(newPoints);
    }

    _.each(routeChunks, function (chunk, i) {
      let waypoints = _.map(chunk, point => {
        return L.Routing.waypoint(L.latLng(point.lat, point.lng), point.caption, { allowUTurn: true });
      });

      let plan = L.Routing.plan(waypoints, {
        createMarker: function (j, wp, n) {
          let pnt = chunk[j],
              marker,
              icon;

          if (pnt.icon) {
            icon = getIcon(pnt.icon.name, pnt.icon.options);
          }
          if (pnt.caption) {
            let typ = (i === 0 && j === 0) ? '_start' : (i === routeChunks.length - 1 && j === n - 1) ? '_end' : 'point';
            marker = L.marker(wp.latLng, {
              icon: icon || getIcon('check' + typ, {
                iconAnchor: [10, 9],
                iconSize: [20, 20]
              }),
              draggable: pnt.draggable
            });
            routeMarkers[pnt.caption] = marker;
          } else {
            let props = { draggable: pnt.draggable };
            if (icon) props.icon = icon;
            marker = L.marker(wp.latLng, props);
          }

          if (pnt.title) {
            let popup = new L.Popup({
              offset: pnt.caption ? [0, 33] : [0, 10]
            });
            popup.setContent(pnt.title);
            marker.bindPopup(popup).openPopup();
          }
          if (pnt.tooltip) {
            marker.bindTooltip(pnt.tooltip.text, pnt.tooltip.options);
          }
          return marker;
        }
      });

      let route = L.Routing.control({
        router: L.Routing.osrmv1(OSRMUrls[profileMode]),
        waypoints: waypoints,
        language: langs.langCode,
        plan: plan,
        addWaypoints: false,
        show: false,
        fitSelectedRoutes: false,
        waypointMode: 'snap',

        routeLine: function (route) {
          const p = L.polyline(route.coordinates, {
            color: options.routeLineColor || '#708EE8',
            weight: 5,
            lineJoin: 'bevel',
            smoothFactor: 1
          });

          if (options.showDirection !== false) {
            p.setText(' > ', {
              repeat: true,
              attributes: {
                fill: options.routeLineTextColor || '#B7C6F3',
                dy: 4.5,
                style: `font-family: sans-serif;`
              }
            });
          }
          return p;
        }
      }).addTo(map);

      if (options.waypointsChanged) {
        route.on('waypointschanged', function (wps) {
          options.waypointsChanged(wps.waypoints);
        });
      }

      if (options.routePlan) {
        route.on('routeselected', function (ev) {
          let route = {
            instructions: ev.route.instructions,
            totalDistance: ev.route.summary.totalDistance,
            totalTime: ev.route.summary.totalTime
          };
          options.routePlan(route);
        });
      }

      routeControls.push(route);
    });
  }

  function removeRoute() {
    _.each(routeControls, route => map.removeControl(route));
    routeControls = [];
    routeChunks = [];
    routeMarkers = {};
  }

  function changeProfile(profile){
    if(!profiles.includes(profile)) return;
    const cls = _.find(profileMainIcon.classList, x => x.startsWith('fa-'));
    profileMainIcon.classList.remove(cls);
    profileMainIcon.classList.add('fa-' + profile);
    profileMode = profile;
    _.each(routeControls, function (rc) {
      rc.getRouter().options.serviceUrl = OSRMUrls[profile].serviceUrl;
      rc.getRouter().options.profile = OSRMUrls[profile].profile;
      rc.route();
    });
  }

  function routeMarkerLatLng(key) {
    return routeMarkers[key] ? routeMarkers[key].getLatLng() : {};
  }

  function removePolygon(key) {
    if (!polygons[key]) return;
    map.removeLayer(polygons[key]);
    delete polygons[key];
  }

  function addPolygon(key, latlngs, options, name = null) {
    removePolygon(key);
    polygons[key] = L.polygon(latlngs, options).addTo(map);
    if (name) {
      polygons[key].bindTooltip(name, { permanent: true, direction: "center" }).openTooltip();
    }
  }

  // for select mode
  function addSelectionHandler(callback) {
    mapSelectionHandlers.push(callback);
  }

  resolveApi();

  return deferredApi;
}
