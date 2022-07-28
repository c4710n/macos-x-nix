#! /usr/bin/env nix-shell
#! nix-shell -i elixir -p elixir

Mix.install([
  {:jason, "> 0.0.0"}
])

defmodule DHub.CLI do
  @docker_cmd "docker"

  def run(args) do
    {parsed, _argv, _errors} =
      OptionParser.parse(args,
        strict: [owner: :string, repo: :string, image: :string],
        aliases: [o: :owner, r: :repo, i: :image]
      )

    with {:ok, {owner, repo}} <- auto_detect_repo_info(),
         :ok <- check(owner, repo),
         {:ok, hash} <- get_repo_hash() do
      date = Date.utc_today()
      owner = Keyword.get(parsed, :owner, owner)
      repo = Keyword.get(parsed, :repo, repo)
      image = Keyword.get(parsed, :image, repo)
      host = find_host(owner)
      name = "#{host}/#{owner}/#{repo}/#{image}:#{date}_#{hash}"

      IO.puts("""
      Hey, I'm trying to build:
      + #{name}

      * * *
      """)

      cmd("#{@docker_cmd} build -t #{name} .", into: IO.stream())
      cmd("#{@docker_cmd} push #{name}", into: IO.stream())

      IO.puts("""

      * * *

      Image has been built:
      + #{name}
      """)
    else
      {:error, _, message} ->
        IO.puts("Error: #{message}")
        help()
    end
  end

  defp help() do
    IO.puts("""

    Usage:

      #{current_cmd_name()} [--owner owner] [--repo repo] [--image image]

    """)
  end

  defp check(owner, _repo) do
    cond do
      owner not in available_owners() ->
        {:error, :bad_argv, "unknown owners, available owners are #{inspect(available_owners())}"}

      true ->
        :ok
    end
  end

  defp auto_detect_repo_info() do
    case cmd("git remote get-url origin") do
      {url, 0} ->
        <<"git@github.com:" <> identifier>> = url

        [owner, repo] =
          identifier
          |> String.trim()
          |> String.trim(".git")
          |> String.split("/")

        {:ok, {owner, repo}}

      _ ->
        {:error, :git, "not a git repo"}
    end
  end

  defp get_repo_hash() do
    case cmd("git rev-parse --short HEAD") do
      {hash, 0} -> {:ok, String.trim(hash)}
      _ -> {:error, :git, "not a git repo"}
    end
  end

  def current_cmd_name() do
    filename = __ENV__.file
    Path.basename(filename, Path.extname(filename))
  end

  defp cmd(line, opts \\ []) do
    {command, args} =
      line
      |> String.split()
      |> List.pop_at(0)

    System.cmd(command, args, opts)
  end

  def find_host(owner) do
    config()
    |> Enum.find(fn section ->
      owner in Map.fetch!(section, "available_owners")
    end)
    |> get_in(["host"])
  end

  defp available_owners() do
    config()
    |> Enum.map(fn section ->
      Map.fetch!(section, "available_owners")
    end)
    |> Enum.reduce([], fn owners, acc ->
      owners ++ acc
    end)
    |> Enum.uniq()
  end

  defp config() do
    "~/.config/#{current_cmd_name()}/hosts.json"
    |> Path.expand()
    |> File.read()
    |> case do
      {:ok, result} ->
        Jason.decode!(result)

      _ ->
        []
    end
  end
end

DHub.CLI.run(System.argv())
