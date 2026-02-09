import request from "@/utils/request.js";

export function orderComment(data) {
    return request.post('order/comment', data);
}