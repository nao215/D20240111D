<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Services\NoteService;

class NoteController extends Controller
{
    protected $noteService;

    public function __construct(NoteService $noteService)
    {
        $this->noteService = $noteService;
    }

    public function delete(Request $request, $id)
    {
        $result = $this->noteService->delete($id);

        if ($result) {
            // New code and existing code have been combined to provide a consistent message
            return response()->json([
                'status' => 200,
                'message' => "Note has been successfully deleted." // New message
            ]);
        } else {
            // Handle the case where the note could not be deleted
            return response()->json([
                'status' => 500,
                'message' => "Failed to delete the note."
            ]);
        }
    }

    // ... other methods in the controller
}
