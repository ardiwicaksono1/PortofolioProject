------

select *
from PortofolioProject..CovidDeaths
where continent is not null
order by 3,4

select *
from PortofolioProject..CovidVaccinations
order by 3,4

----DIBEDAH BERDASARKAN NEGARA

select location, date, total_cases, new_cases, total_deaths, population
from PortofolioProject..CovidDeaths
order by 1,2

--Total Cases vs Total Deaths in Indonesia
--Memperlihatkan presentase penduduk meninggal dunia karena Covid

select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as Presentase_Kematian
from PortofolioProject..CovidDeaths
where location = 'Indonesia'
order by 1,2

--Total Cases vs Population - 
--memperlihatkan presentase penduduk tertular covid di Indonesia
select location, date,total_cases, population, (total_cases/population)*100 as Presentase_terdampak_Covid
from PortofolioProject..CovidDeaths
where location = 'Indonesia'
order by 2

--Highest Infection Rate compared to Population
--memperlihatkan tingkat infeksi dari berbagai negara berdasarkan perbandingan pada populasi 
select location
, population
, max(total_cases) as max_kasus
, Max(total_cases/population)*100 as maks_presentase_penduduk_covid
from PortofolioProject..CovidDeaths
where continent is not null and total_cases is not null and population is not null
group by location
,population
order by maks_presentase_penduduk_covid desc

--Memperlihatkan negara mana dengan kematian tertinggi berdasarkan perbandingan dengan populasi
select location
, population
, max(cast(total_deaths as int)) as max_kasus_kematian
, Max(total_deaths/population)*100 as maks_presentase_penduduk_covid_meninggal
from PortofolioProject..CovidDeaths
where population is not null and total_deaths is not null
group by location
,population
order by maks_presentase_penduduk_covid_meninggal desc


----DIBEDAH BERDASARKAN BENUA
select *
from PortofolioProject..CovidDeaths
where continent is not null
order by location desc

--Memperlihatkan kasus kematian tertinggi dari setiap benua
select continent
, max(cast(total_deaths as int)) as Total_Kematian 
from PortofolioProject..CovidDeaths
where continent is not null
group by continent
order by Total_Kematian desc

--Memperlihatkan kasus persentase kematian tertinggi(total kematian/populasi) dari setiap benua
select continent
, max(cast(total_deaths as int)) as Total_Kematian 
, max(cast(total_deaths as int)/population)*100 as Persentase_Total_Kematian
from PortofolioProject..CovidDeaths
where continent is not null
group by continent
order by Total_Kematian desc

----ANGKA GLOBAL

select *
from PortofolioProject..CovidDeaths
where continent is not null
order by 3,4

--Percentase Kematian Global setiap waktu
select
date
, sum(new_cases) as TotalCases
, sum(cast(new_deaths as int)) as TotalDeaths
, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortofolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

--Percentase Kematian Global Total
select
 sum(new_cases) as TotalCases
, sum(cast(new_deaths as int)) as TotalDeaths
, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortofolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2

--------------

select *
from PortofolioProject..CovidVaccinations


select *
from PortofolioProject..CovidDeaths Death
Join PortofolioProject..CovidVaccinations Vaccin
	on Death.location = Vaccin.location
	and Death.date = Vaccin.date

--Melihat total penduduk yang sudah divaksin dari berbagai negara (POPULASI VS VAKSINASI)
with PopvsVaksin (Continent, Location, Date, Population, New_Vaccination, TotalPendudukdiVaksin)
as
(
select Death.continent
, Death.location
, Death.date
, Death.population
, Vaccin.new_vaccinations
, SUM(cast(Vaccin.new_vaccinations as int)) over (partition by Death.location order by Death.location, Death.Date) as TotalPendudukdiVaksin
from PortofolioProject..CovidDeaths Death 
Join PortofolioProject..CovidVaccinations Vaccin
	on Death.location = Vaccin.location
	and Death.date = Vaccin.date
where death.continent is not null
)
select *, (TotalPendudukdiVaksin/Population)*100
from PopvsVaksin

DROP TABLE if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Benua nvarchar (255),
Negara nvarchar (255),
Tanggal datetime,
Populasi numeric,
Vaksinasi_Baru numeric,
TotalPendudukdiVaksin numeric
)

insert into #PercentPopulationVaccinated
select Death.continent
, Death.location
, Death.date
, Death.population
, Vaccin.new_vaccinations
, SUM(cast(Vaccin.new_vaccinations as int)) over (partition by Death.location order by Death.location, Death.Date) as TotalPendudukdiVaksin
from PortofolioProject..CovidDeaths Death 
Join PortofolioProject..CovidVaccinations Vaccin
	on Death.location = Vaccin.location
	and Death.date = Vaccin.date
where death.continent is not null

select *, (TotalPendudukdiVaksin/Populasi)*100
from #PercentPopulationVaccinated

----view untuk visualisasion nanti
create view PercentPopulationVaccinated as 
select Death.continent
, Death.location
, Death.date
, Death.population
, Vaccin.new_vaccinations
, SUM(cast(Vaccin.new_vaccinations as int)) over (partition by Death.location order by Death.location, Death.Date) as TotalPendudukdiVaksin
from PortofolioProject..CovidDeaths Death 
Join PortofolioProject..CovidVaccinations Vaccin
	on Death.location = Vaccin.location
	and Death.date = Vaccin.date
where death.continent is not null

select * from PercentPopulationVaccinated