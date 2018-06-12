/**
 * @return {number}
 */

function ISO8601_week_no(dt) {
    return Math.ceil((new Date(dt) -new Date(dt.getFullYear(),0,1))/(3600000*24*7));
}
;
