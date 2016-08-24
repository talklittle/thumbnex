defmodule Thumbnex.Gifs do

  @doc """
  Return the GIF duration in seconds.
  """
  def duration(gif_path) do
    {result, 0} = System.cmd identify_path(), ~w(-format %T\\n #{gif_path})
    centiseconds = Enum.reduce(String.split(result), 0, fn(x, acc) ->
      String.to_integer(String.strip(x)) + acc
    end)
    centiseconds / 100
  end

  defp identify_path do
    Application.get_env(:thumbnex, :identify_path, "identify")
  end
end