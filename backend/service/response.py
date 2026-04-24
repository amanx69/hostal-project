"""
service/response.py
-------------------
Uniform API response helpers used across every app.

Usage:
    from service.response import success_response, error_response
"""
from rest_framework.response import Response
from rest_framework import status as http_status_module


def success_response(
    data: dict,
    http_status: int = http_status_module.HTTP_200_OK,
) -> Response:
    """
    Wrap a successful result in the standard envelope.

    Returns:
        {
            "success": true,
            ... (all keys from `data` merged at the top level)
        }
    """
    return Response({"success": True, **data}, status=http_status)


def error_response(
    message: str,
    http_status: int = http_status_module.HTTP_400_BAD_REQUEST,
    errors: dict | None = None,
) -> Response:
    """
    Wrap an error in the standard envelope.

    Returns:
        {
            "success": false,
            "message": "<message>",
            "errors": { ... }   ← only present when `errors` is provided
        }
    """
    body: dict = {"success": False, "message": message}
    if errors is not None:
        body["errors"] = errors
    return Response(body, status=http_status)
