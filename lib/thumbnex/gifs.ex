defmodule Thumbnex.Gifs do
  @doc """
  Return the GIF duration in seconds.
  """
  def duration(gif_path) do
    {result, 0} = System.cmd(identify_path(), ~w(-format %T\\n #{gif_path}))

    centiseconds =
      Enum.reduce(String.split(result), 0, fn x, acc ->
        String.to_integer(String.trim(x)) + acc
      end)

    centiseconds / 100
  end

  def optimize_mogrify_image(image) do
    image
    |> Mogrify.custom("fuzz", "10%")
    |> Mogrify.custom("layers", "Optimize")
  end

  defp identify_path do
    Application.get_env(:thumbnex, :identify_path, "identify")
  end
end
