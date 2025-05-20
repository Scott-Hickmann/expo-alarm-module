function getParam(param, key) {
  if (param && (param[key] !== null || param[key] !== undefined)) {
    return param[key];
  }
}
function toAndroidDays(daysArray) {
  if (daysArray) {
    if (Array.isArray(daysArray)) {
      return daysArray.map(day => (day + 1) % 7);
    } else {
      return daysArray;
    }
  } else {
    return [];
  }
}
function fromAndroidDays(daysArray) {
  if (daysArray) {
    if (Array.isArray(daysArray)) {
      return daysArray.map(d => d === 0 ? 6 : d - 1);
    } else {
      return daysArray;
    }
  } else {
    return [];
  }
}
function fromIOSDays(dayUTCSeconds) {
  if (dayUTCSeconds) {
    return new Date(new Date(0).setUTCSeconds(dayUTCSeconds));
  } else {
    return;
  }
}
export { getParam, toAndroidDays, fromAndroidDays, fromIOSDays };
//# sourceMappingURL=utils.js.map