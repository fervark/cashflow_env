#!/bin/bash

function interpolate {
  template=$1
  pattern='(?<=\${).*?:.*?(?=})'
  # если паттерн не найден, то список будет состоять из одной пустой линии,
  # учитываем этот  случай, возвращая параметр как есть, после первой же итерации.
  while IFS=":" read -r host var; do
    [[ -z "$host" ]] && continue;
    value="$(docker exec "$host" printenv "$var")";
    template="${template/\$\{$host:$var\}/"$value"}"
  done <<< "$(echo "$template" | grep -oP "$pattern")"
  echo "$template"
}

declare -A env
declare -a order

service=$1
configs_dir="./services/$service/config"
base="$configs_dir/base.env";
extended="$configs_dir/extended.env";
dest="../$service/.env"
rm "$dest" 2> /dev/null;

while IFS="=" read -r key value; do
  # игнорируем пустые строки и комментарии
  { [[ -z "$key" ]] || [[ $key == \#* ]]; }  && continue;
  # запоминаем порядок появления переменных
  ! [[ -v env["$key"] ]] && order+=("$key");
  env["$key"]="$value"
done <<< "$(cat "$base" "$extended")"

for i in "${!order[@]}"; do
  var=${order[$i]};
  value="${env[$var]}";
  value=$(interpolate "$value");
  echo "$var=$value" >> "$dest";
done